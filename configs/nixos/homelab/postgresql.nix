{
  config,
  globals,
  lib,
  localLib,
  pkgs,
  secrets,
  ...
}:
let
  ports.postgresql = 5432;
in
{
  options.local.postgresql = {
    enable = lib.mkEnableOption "postgresql";
    databases = lib.mkOption {
      default = [ ];
      type = lib.types.listOf lib.types.str;
      description = ''
        Names of databases (and matching owner roles) to create. Each
        entry N is only reachable over the network as database/role N
        (never as the postgres superuser), and requires an agenix
        secret named `postgresql_N.age` holding N's password, encrypted
        for `nas` plus whichever swarm hosts need to connect.
      '';
    };
  };
  config = lib.mkIf config.local.postgresql.enable {
    age.secrets =
      lib.genAttrs (map (name: "postgresql_${name}.age") config.local.postgresql.databases)
        (name: {
          file = "${secrets}/${name}";
        });
    networking.firewall = localLib.mkFirewallRules {
      service = "postgresql";
      sources = globals.networking.swarmAddresses;
      tcpPorts = [ ports.postgresql ];
    };
    services.postgresql = {
      authentication = lib.mkAfter (
        lib.concatMapStrings (
          name:
          lib.concatMapStrings (
            address:
            "host  ${name}  ${name}  ${address}/${
              if lib.hasInfix ":" address then "128" else "32"
            }  scram-sha-256\n"
          ) globals.networking.swarmAddresses
        ) config.local.postgresql.databases
      );
      enable = true;
      ensureDatabases = config.local.postgresql.databases;
      ensureUsers = map (name: {
        inherit name;
        ensureDBOwnership = true;
      }) config.local.postgresql.databases;
      settings = {
        listen_addresses = lib.mkForce "localhost,${
          globals.networking.hosts.${config.networking.hostName}.ipv4
        }";
      };
    };
    systemd.services.postgresql-set-passwords = lib.mkIf (config.local.postgresql.databases != [ ]) {
      after = [ "postgresql-setup.service" ];
      description = "Set PostgreSQL role passwords from agenix secrets";
      requires = [ "postgresql-setup.service" ];
      script = lib.concatMapStrings (name: ''
        PASSWORD_FILE="${config.age.secrets."postgresql_${name}.age".path}"
        if [ -f "$PASSWORD_FILE" ]; then
          ${pkgs.util-linux}/bin/runuser -u postgres -- \
            ${config.services.postgresql.package}/bin/psql -h /run/postgresql -U postgres -d postgres -c \
              "ALTER ROLE \"${name}\" WITH PASSWORD '$(cat "$PASSWORD_FILE")'"
        else
          echo "postgresql_${name}.age not yet available — deploy after rekeying"
        fi
      '') config.local.postgresql.databases;
      serviceConfig = {
        RemainAfterExit = true;
        Type = "oneshot";
      };
      wantedBy = [ "multi-user.target" ];
    };
    systemd.services.postgresql-backup = lib.mkIf (config.local.postgresql.databases != [ ]) {
      after = [ "postgresql.service" ];
      description = "Dump PostgreSQL databases for backup";
      requires = [ "postgresql.service" ];
      script = lib.concatMapStrings (name: ''
        ${config.services.postgresql.package}/bin/pg_dump -h /run/postgresql -U postgres -Fc \
          -f /mnt/data/postgresql-backups/${name}.dump.tmp ${name}
        chmod 0644 /mnt/data/postgresql-backups/${name}.dump.tmp
        mv /mnt/data/postgresql-backups/${name}.dump.tmp /mnt/data/postgresql-backups/${name}.dump
      '') config.local.postgresql.databases;
      serviceConfig = {
        ExecStartPre = [
          (
            "+"
            + pkgs.writeShellScript "postgresql-create-backup-dir" ''
              mkdir -p /mnt/data/postgresql-backups
              chown postgres:postgres /mnt/data/postgresql-backups
              chmod 0755 /mnt/data/postgresql-backups
            ''
          )
        ];
        Type = "oneshot";
        User = "postgres";
      };
      unitConfig.RequiresMountsFor = [ "/mnt/data" ];
    };
    systemd.timers.postgresql-backup = lib.mkIf (config.local.postgresql.databases != [ ]) {
      description = "Daily PostgreSQL dump timer";
      timerConfig = {
        OnCalendar = "*-*-* 12:00:00";
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };
  };
}
