{
  config,
  lib,
  localLib,
  ...
}:
let
  cfg = config.local.attic;
  ports.atticd = 8090;
in
{
  options.local.attic = {
    enable = lib.mkEnableOption "attic binary cache";
    storagePath = lib.mkOption {
      default = "/mnt/attic";
      type = lib.types.str;
      description = ''
        Where atticd keeps NAR chunks. On nas this is the mountpoint of the
        VM's data disk, so a full cache can't fill the root filesystem.
      '';
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      # Holds ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64, generated with
      # `openssl genrsa -traditional 4096 | base64 -w0`.
      age.secrets."atticd_env.age".file = ../../../secrets/atticd_env.age;
      services.atticd = {
        enable = true;
        environmentFile = config.age.secrets."atticd_env.age".path;
        settings = {
          api-endpoint = "https://attic.${config.local.caddy.domain}/";
          database.url = "postgresql:///atticd?host=/run/postgresql&user=atticd";
          garbage-collection.default-retention-period = "30 days";
          listen = "127.0.0.1:${toString ports.atticd}";
          storage = {
            type = "local";
            path = cfg.storagePath;
          };
        };
      };
      services.postgresql = {
        enable = true;
        ensureDatabases = [ "atticd" ];
        ensureUsers = [
          {
            name = "atticd";
            ensureDBOwnership = true;
          }
        ];
      };
      # The upstream unit uses DynamicUser, whose uid can change between
      # boots and lose ownership of storage outside /var/lib. A static user
      # keeps the data disk's files readable.
      systemd.services.atticd = {
        serviceConfig.DynamicUser = lib.mkForce false;
        unitConfig.RequiresMountsFor = [ cfg.storagePath ];
      };
      systemd.tmpfiles.rules = [ "d ${cfg.storagePath} 0750 atticd atticd -" ];
      users.groups.atticd = { };
      users.users.atticd = {
        group = "atticd";
        isSystemUser = true;
      };
    })
    (lib.mkIf (cfg.enable && config.services.caddy.enable) {
      services.caddy.virtualHosts = localLib.mkCaddyVirtualHosts {
        attic = "reverse_proxy 127.0.0.1:${toString ports.atticd}";
      };
    })
  ];
}
