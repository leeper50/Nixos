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
    (lib.mkIf (cfg.enable && config.services.freshrss.webserver == "nginx") {
      services.nginx.virtualHosts."${freshrssDomain}" = {
        forceSSL = true;
        quic = true;
        useACMEHost = globals.domain;
        locations."/internal/authelia/authz" = {
          extraConfig = ''
            internal;
            proxy_pass http://127.0.0.1:${toString autheliaPort}/api/authz/auth-request;
            proxy_set_header X-Original-Method $request_method;
            proxy_set_header X-Original-URL $scheme://$host$request_uri;
            proxy_set_header X-Forwarded-For $remote_addr;
            proxy_set_header Content-Length "";
            proxy_set_header Connection "";
            proxy_pass_request_body off;
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
            proxy_redirect http:// $scheme://;
            proxy_http_version 1.1;
            proxy_cache_bypass $cookie_session;
            proxy_no_cache $cookie_session;
          '';
        };
        locations."^~ /api/".extraConfig = ''
          fastcgi_pass unix:${config.services.phpfpm.pools.freshrss.socket};
          fastcgi_split_path_info ^(.+\.php)(/.*)$;
          set $path_info $fastcgi_path_info;
          fastcgi_param PATH_INFO $path_info;
          include ${pkgs.nginx}/conf/fastcgi_params;
          include ${pkgs.nginx}/conf/fastcgi.conf;
        '';
        locations."~ ^.+?\\.php(/.*)?$".extraConfig = ''
          auth_request /internal/authelia/authz;
          auth_request_set $user $upstream_http_remote_user;
          fastcgi_param REMOTE_USER $user;
          auth_request_set $redirection_url $upstream_http_location;
          error_page 401 =302 $redirection_url;
        '';
      };
    })
  ];
}
