{
  config,
  lib,
  localLib,
  ...
}:
let
  port = 8082;
in
{
  options.local.gotify = {
    enable = lib.mkEnableOption "gotify";
  };
  config = lib.mkMerge [
    (lib.mkIf config.local.gotify.enable {
      services.gotify = {
        enable = true;
        environment = {
          GOTIFY_DATABASE_DIALECT = "sqlite3";
          GOTIFY_REGISTRATION = "false";
          GOTIFY_SERVER_LISTENADDR = "127.0.0.1";
          GOTIFY_SERVER_PORT = port;
          GOTIFY_SERVER_CORS_ALLOWORIGINS = "^https://g\\.dellhplaptop\\.xyz$";
          GOTIFY_SERVER_STREAM_ALLOWEDORIGINS = "^g\\.dellhplaptop\\.xyz$";
          GOTIFY_SERVER_TRUSTEDPROXIES = "127.0.0.1";
        };
      };
    })
    (lib.mkIf (config.local.gotify.enable && config.services.caddy.enable) {
      services.caddy.virtualHosts = localLib.mkCaddyVirtualHosts {
        g = {
          extraConfig = "reverse_proxy 127.0.0.1:${toString port}";
          ipFilter = "friendly_ips";
        };
      };
    })
  ];
}
