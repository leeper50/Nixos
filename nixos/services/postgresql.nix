{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.local.postgresql;
  swarmNodes = {
    ipv4 = [
      "10.0.0.21"
      "10.0.0.22"
      "10.0.0.23"
    ];
    ipv6 = [
      "2600:1702:58c1:9acf::21"
      "2600:1702:58c1:9acf::22"
      "2600:1702:58c1:9acf::23"
    ];
  };
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
  config = lib.mkIf cfg.enable {
    networking.firewall.extraInputRules = ''
      ip saddr { ${lib.concatStringsSep ", " swarmNodes.ipv4} } tcp dport 5432 accept
      ip6 saddr { ${lib.concatStringsSep ", " swarmNodes.ipv6} } tcp dport 5432 accept
    '';
    services.postgresql = {
      authentication = lib.mkAfter (
        lib.concatMapStrings (
          name:
          lib.concatMapStrings (ip: "host  ${name}  ${name}  ${ip}/32  scram-sha-256\n") swarmNodes.ipv4
          + lib.concatMapStrings (ip: "host  ${name}  ${name}  ${ip}/128  scram-sha-256\n") swarmNodes.ipv6
        ) cfg.databases
      );
      enable = true;
      ensureDatabases = cfg.databases;
      ensureUsers = map (name: {
        inherit name;
        ensureDBOwnership = true;
      }) cfg.databases;
      settings = {
        listen_addresses = lib.mkForce "localhost,10.0.0.52";
      };
    };
    systemd.services.postgresql = {
      serviceConfig.ExecStartPre = lib.mkBefore [
        (
          "+"
          + pkgs.writeShellScript "postgresql-create-backup-dir" ''
            mkdir -p /mnt/data/postgresql-backups
            chown postgres:postgres /mnt/data/postgresql-backups
          ''
        )
      ];
    };
    systemd.services.postgresql-set-passwords = lib.mkIf (cfg.databases != [ ]) {
      after = [ "postgresql-setup.service" ];
      description = "Set PostgreSQL role passwords from agenix secrets";
      requires = [ "postgresql-setup.service" ];
      script = lib.concatMapStrings (name: ''
        PASSWORD_FILE="/run/agenix/postgresql_${name}.age"
        if [ -f "$PASSWORD_FILE" ]; then
          ${pkgs.util-linux}/bin/runuser -u postgres -- \
            ${config.services.postgresql.package}/bin/psql -h /run/postgresql -U postgres -d postgres -c \
              "ALTER ROLE \"${name}\" WITH PASSWORD '$(cat "$PASSWORD_FILE")'"
        else
          echo "postgresql_${name}.age not yet available — deploy after rekeying"
        fi
      '') cfg.databases;
      serviceConfig = {
        RemainAfterExit = true;
        Type = "oneshot";
      };
      wantedBy = [ "multi-user.target" ];
    };
    systemd.services.postgresql-backup = lib.mkIf (cfg.databases != [ ]) {
      after = [ "postgresql.service" ];
      description = "Dump PostgreSQL databases for backup";
      requires = [ "postgresql.service" ];
      script = lib.concatMapStrings (name: ''
        ${config.services.postgresql.package}/bin/pg_dump -h /run/postgresql -U postgres -Fc \
          -f /mnt/data/postgresql-backups/${name}.dump.tmp ${name}
        mv /mnt/data/postgresql-backups/${name}.dump.tmp /mnt/data/postgresql-backups/${name}.dump
      '') cfg.databases;
      serviceConfig = {
        Type = "oneshot";
        User = "postgres";
      };
    };
    systemd.timers.postgresql-backup = lib.mkIf (cfg.databases != [ ]) {
      description = "Daily PostgreSQL dump timer";
      timerConfig = {
        OnCalendar = "*-*-* 12:00:00";
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };
  };
}
