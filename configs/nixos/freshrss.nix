{
  config,
  lib,
  globals,
  pkgs,
  ...
}:
{
  config = lib.mkMerge [
    {
      services.freshrss = {
        api.enable = true;
        authType = "form";
        baseUrl = "https://rss.${globals.domain}";
        dataDir = "/var/lib/freshrss";
        defaultUser = globals.username;
        enable = true;
        language = "en";
        passwordFile = pkgs.writeText "freshrss-bootstrap-password" "changeme";
        user = "freshrss";
        virtualHost = "rss.${globals.domain}";
      };
    }
    (lib.mkIf (config.services.freshrss.webserver == "nginx") {
      services.nginx.virtualHosts."rss.${globals.domain}" = {
        forceSSL = true;
        quic = true;
        useACMEHost = globals.domain;
      };
    })
  ];
}
