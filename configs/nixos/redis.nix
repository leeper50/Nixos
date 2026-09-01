{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.local.redis;
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
  ports = lib.listToAttrs (lib.imap0 (i: name: lib.nameValuePair name (6379 + i)) cfg.databases);
in
{
  options.local.redis = {
    enable = lib.mkEnableOption "redis";
    databases = lib.mkOption {
      default = [ ];
      type = lib.types.listOf lib.types.str;
      description = ''
        Names of redis-server instances to create. Each entry N gets its
        own instance on its own port (assigned sequentially in list order,
        starting at 6379 — reordering this list reassigns ports), reachable
        over the network only from swarm nodes, and requires an agenix
        secret named `redis_N.age` holding N's password, encrypted for
        `nas` plus whichever swarm hosts need to connect.
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    networking.firewall.extraInputRules = ''
      ip saddr { ${lib.concatStringsSep ", " swarmNodes.ipv4} } tcp dport { ${lib.concatStringsSep ", " (
        map toString (lib.attrValues ports)
      )} } accept
      ip6 saddr { ${lib.concatStringsSep ", " swarmNodes.ipv6} } tcp dport { ${lib.concatStringsSep ", " (
        map toString (lib.attrValues ports)
      )} } accept
    '';
    services.redis = {
      package = pkgs.valkey;
      servers = lib.mapAttrs (name: port: {
        enable = true;
        bind = "127.0.0.1 10.0.0.52";
        inherit port;
        requirePassFile = "/run/agenix/redis_${name}.age";
      }) ports;
    };
    systemd.services.redis-backup = lib.mkIf (cfg.databases != [ ]) {
      after = map (name: "redis-${name}.service") cfg.databases;
      description = "Dump Redis databases for backup";
      requires = map (name: "redis-${name}.service") cfg.databases;
      script = ''
        mkdir -p /mnt/data/redis-backups
      ''
      + lib.concatMapStrings (name: ''
        PASSWORD_FILE="/run/agenix/redis_${name}.age"
        if [ -f "$PASSWORD_FILE" ]; then
          ${pkgs.valkey}/bin/redis-cli -p ${toString ports.${name}} -a "$(cat "$PASSWORD_FILE")" --no-auth-warning \
            --rdb /mnt/data/redis-backups/${name}.rdb.tmp
          mv /mnt/data/redis-backups/${name}.rdb.tmp /mnt/data/redis-backups/${name}.rdb
        else
          echo "redis_${name}.age not yet available — deploy after rekeying"
        fi
      '') cfg.databases;
      serviceConfig = {
        Type = "oneshot";
      };
    };
    systemd.timers.redis-backup = lib.mkIf (cfg.databases != [ ]) {
      description = "Daily Redis dump timer";
      timerConfig = {
        OnCalendar = "*-*-* 12:00:00";
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };
  };
}
