{
  config,
  lib,
  globals,
  pkgs,
  ...
}:
let
  cfg = config.local.freshrss;
  freshrssDomain = "rss.${globals.domain}";
  autheliaPort = 9091;
in
{
  options.local.freshrss = {
    enable = lib.mkEnableOption "RSS reader";
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      services.freshrss = {
        api.enable = true;
        authType = "http_auth";
        baseUrl = "https://${freshrssDomain}";
        dataDir = "/var/lib/freshrss";
        defaultUser = globals.username;
        enable = true;
        language = "en";
        passwordFile = pkgs.writeText "freshrss-bootstrap-password" "changeme";
        user = "freshrss";
        virtualHost = freshrssDomain;
      };
    })
    (lib.mkIf (cfg.enable && config.local.authelia.enable) {
      systemd.services.freshrss = {
        after = [ "authelia-main.service" ];
        wants = [ "authelia-main.service" ];
      };
    })
    (lib.mkIf (cfg.enable && config.local.caddy.enable or false) {
      services.freshrss.webserver = "caddy";
      services.caddy.virtualHosts."${freshrssDomain}" = {
        extraConfig = lib.mkForce ''
          import hardening
          route {
            request_header -Remote-User
            @protected not path /api/*
            forward_auth @protected 127.0.0.1:${toString autheliaPort} {
              uri /api/authz/forward-auth
              copy_headers Remote-User
            }
            root * ${config.services.freshrss.package}/p
            php_fastcgi unix/${config.services.phpfpm.pools.freshrss.socket} {
              env FRESHRSS_DATA_PATH ${config.services.freshrss.dataDir}
              env REMOTE_USER {http.request.header.Remote-User}
            }
            file_server
          }
        '';
        useACMEHost = globals.domain;
      };
    })
  ];
}
