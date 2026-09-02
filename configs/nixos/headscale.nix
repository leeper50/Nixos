{
  config,
  globals,
  lib,
  ...
}:
let
  cfg = config.local.headscale;
  pass = config.age.secrets;

  authDomain = "login.${globals.domain}";
  headscaleDomain = "hd.${globals.domain}";
in
{
  options.local.headscale = {
    enable = lib.mkEnableOption "Headscale coordination server with Headplane admin UI";
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      services.headscale = {
        enable = true;
        settings = {
          dns = {
            base_domain = "ts.${globals.domain}";
            magic_dns = true;
            override_local_dns = false;
          };
          server_url = "https://${headscaleDomain}";
        };
      };
      services.headplane = {
        enable = true;
        settings = {
          server = {
            base_url = "https://${headscaleDomain}";
            cookie_secret_path = pass."headplane_cookie_secret.age".path;
            port = 3001;
          };
          headscale.api_key_path = pass."headplane_headscale_api_key.age".path;
        };
      };
    })
    (lib.mkIf (cfg.enable && config.local.authelia.enable) {
      services.headscale.settings = {
        oidc = {
          client_id = "headscale";
          client_secret_path = pass."headscale_oidc_client_secret.age".path;
          issuer = "https://${authDomain}";
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
      services.headplane.settings = {
        oidc = {
          client_id = "headplane";
          client_secret_path = pass."headplane_oidc_client_secret.age".path;
          issuer = "https://${authDomain}";
          use_pkce = true;
          token_endpoint_auth_method = "client_secret_basic";
        };
      };
      systemd.services.headscale = {
        after = [ "authelia-main.service" ];
        wants = [ "authelia-main.service" ];
      };
    })
    (lib.mkIf (cfg.enable && config.services.nginx.enable) {
      services.nginx.virtualHosts.${headscaleDomain} = {
        forceSSL = true;
        quic = true;
        useACMEHost = globals.domain;
        locations."/" = {
          extraConfig = "proxy_buffering off;";
          proxyPass = "http://127.0.0.1:${toString config.services.headscale.port}";
          proxyWebsockets = true;
        };
        locations."/admin".proxyPass =
          "http://127.0.0.1:${toString config.services.headplane.settings.server.port}";
      };
    })
  ];
}
