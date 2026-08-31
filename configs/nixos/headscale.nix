{
  config,
  globals,
  lib,
  ...
}:
let
  cfg = config.local.headscale;
  pass = config.age.secrets;
  headscaleDomain = "headscale.${globals.domain}";
in
{
  options.local.headscale = {
    enable = lib.mkEnableOption "Headscale coordination server with Headplane admin UI";
  };
  config = lib.mkIf cfg.enable {
    services.headscale = {
      enable = true;
      settings = {
        dns = {
          base_domain = "ts.${globals.domain}";
          magic_dns = true;
          override_local_dns = false;
        };
        server_url = "https://${headscaleDomain}";
        oidc = {
          client_id = "headscale";
          client_secret_path = pass."headscale_oidc_client_secret.age".path;
          issuer = "https://auth.${globals.domain}";
          only_start_if_oidc_is_available = true;
          pkce = {
            enabled = true;
            method = "S256";
          };
          scope = [
            "openid"
            "profile"
            "email"
            "groups"
          ];
        };
      };
    };
    systemd.services.headscale = {
      after = [ "authelia-headscale.service" ];
      wants = [ "authelia-headscale.service" ];
    };
    services.headplane = {
      enable = true;
      settings = {
        server = {
          base_url = "https://${headscaleDomain}";
          cookie_secret_path = pass."headplane_cookie_secret.age".path;
        };
        oidc = {
          client_id = "headplane";
          client_secret_path = pass."headplane_oidc_client_secret.age".path;
          issuer = "https://auth.${globals.domain}";
          use_pkce = true;
        };
        headscale = {
          api_key_path = pass."headplane_headscale_api_key.age".path;
        };
      };
    };

    services.nginx.virtualHosts.${headscaleDomain} = {
      forceSSL = true;
      useACMEHost = globals.domain;
      locations."/" = {
        extraConfig = "proxy_buffering off;";
        proxyPass = "http://127.0.0.1:${toString config.services.headscale.port}";
        proxyWebsockets = true;
      };
      locations."/admin".proxyPass = "http://127.0.0.1:${toString config.services.headplane.settings.server.port}";
    };
  };
}
