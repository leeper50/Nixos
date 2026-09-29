{
  config,
  globals,
  lib,
  self,
  ...
}:
let
  cfg = config.local.headscale;
  pass = config.age.secrets;

  authDomain = "login.${globals.domains.primary}";
  headscaleDomain = "hd.${globals.domains.primary}";

  # Setup explicit extra records from caddy virtual host from each machine.
  tailnetRecords = lib.concatLists (
    lib.mapAttrsToList
      (
        hostName: hostConfig:
        let
          ips = globals.networking.tailnet.${hostName};
          suffix = ".${hostName}.${globals.domains.tailnet}";
          names = lib.filter (name: lib.hasSuffix suffix name && !lib.hasPrefix "*" name) (
            lib.attrNames hostConfig.services.caddy.virtualHosts
          );
        in
        lib.optionals (hostConfig.services.tailscale.enable && hostConfig.services.caddy.enable) (
          lib.concatMap (name: [
            {
              inherit name;
              type = "A";
              value = ips.ipv4;
            }
            {
              inherit name;
              type = "AAAA";
              value = ips.ipv6;
            }
          ]) names
        )
      )
      (
        lib.filterAttrs (hostName: _: globals.networking.tailnet ? ${hostName}) (
          lib.mapAttrs (_: system: system.config) self.nixosConfigurations
          // {
            ${config.networking.hostName} = config;
          }
        )
      )
  );
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
            base_domain = "${globals.domains.tailnet}";
            extra_records = tailnetRecords;
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
    (lib.mkIf (cfg.enable && config.services.caddy.enable) {
      services.caddy.virtualHosts.${headscaleDomain} = {
        extraConfig = ''
          handle /admin* {
            reverse_proxy 127.0.0.1:${toString config.services.headplane.settings.server.port}
          }
          handle {
            reverse_proxy 127.0.0.1:${toString config.services.headscale.port} {
              flush_interval -1
            }
          }
        '';
        useACMEHost = globals.domains.primary;
      };
    })
  ];
}
