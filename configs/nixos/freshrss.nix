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
        # Bootstrap password only — change it via Settings > Profile >
        # Password in the FreshRSS web UI right after first login. Don't
        # touch defaultUser/authType/baseUrl/database here afterwards, or
        # freshrss-config.service reruns update-user and resets it back to
        # this value.
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
