{
  config,
  lib,
  localLib,
  ...
}:
let
  cfg = config.local.mealie;
  port = 9000;
in
{
  options.local.mealie = {
    enable = lib.mkEnableOption "mealie";
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      age.secrets."postgresql_mealie.age".file = ../../secrets/postgresql_mealie.age;
      services.mealie = {
        enable = true;
        listenAddress = "127.0.0.1";
        inherit port;
        credentialsFile = "/run/mealie-env/env";
        settings = {
          "BASE_URL" = "https://m.dellhplaptop.xyz";
          "DB_ENGINE" = "postgres";
          "POSTGRES_SERVER" = "nas.local";
          "TZ" = "America/Chicago";
        };
      };
      systemd.services.mealie-env = {
        before = [ "mealie.service" ];
        description = "Render mealie's database password as an environment file";
        requiredBy = [ "mealie.service" ];
        script = ''
          umask 077
          printf 'POSTGRES_PASSWORD=%s\n' "$(cat ${config.age.secrets."postgresql_mealie.age".path})" \
            > /run/mealie-env/env
        '';
        serviceConfig = {
          RemainAfterExit = true;
          RuntimeDirectory = "mealie-env";
          RuntimeDirectoryMode = "0700";
          Type = "oneshot";
        };
      };
    })
    (lib.mkIf (cfg.enable && config.services.caddy.enable) {
      services.caddy.virtualHosts = localLib.mkCaddyVirtualHosts {
        m = "reverse_proxy 127.0.0.1:${toString port}";
      };
    })
  ];
}
