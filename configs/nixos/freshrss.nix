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
        # database = {
        #   host = "nas.local";
        #   name = "freshrss";
        #   passFile = pass."postgresql_freshrss.age".path;
        #   port = 5432;
        #   type = "pgsql";
        #   user = "freshrss";
        # };
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
        useACMEHost = globals.domain;
      };
    })
  ];
}
