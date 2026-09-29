{
  config,
  globals,
  lib,
  ...
}:
let
  cfg = config.local.caddy;
in
{
  options.local.caddy = {
    domain = lib.mkOption {
      default = "${config.networking.hostName}.${globals.domain}";
      type = lib.types.str;
    };
    enable = lib.mkEnableOption "caddy";
    provider = lib.mkOption {
      default = "cloudflare";
      type = lib.types.enum [
        "cloudflare"
        "porkbun"
      ];
    };
    tsDomain = lib.mkOption {
      default = if config.services.tailscale.enable then "${config.networking.hostName}.ts.${globals.domain}" else null;
      type = lib.types.nullOr lib.types.str;
    };
  };
  options.services.caddy.virtualHosts = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        config.extraConfig = lib.mkIf cfg.enable (lib.mkBefore "import hardening");
      }
    );
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      local.acme = {
        certs = {
          ${cfg.domain} = {
            group = "caddy";
            provider = cfg.provider;
            wildcard = true;
          };
        };
        enable = true;
      };
      networking.firewall = globals.mkFirewallRules {
        service = "caddy";
        sources =
          if config.local.local then
            [
              globals.networking.ipv4.lanSubnet
              globals.networking.ipv6.lanSubnet
            ]
          else
            [
              "0.0.0.0/0"
              "::/0"
            ];
        tcpPorts = [
          80
          443
        ];
        udpPorts = [
          443
        ];
      };
      services = {
        caddy = {
          email = globals.primaryEmail;
          enable = true;
          enableReload = true;
          extraConfig = ''
            (hardening) {
              header {
                X-Content-Type-Options nosniff
                X-Frame-Options SAMEORIGIN
                Referrer-Policy strict-origin-when-cross-origin
                Permissions-Policy "camera=(), microphone=(), geolocation=()"
                Strict-Transport-Security "max-age=31536000; includeSubDomains"
                -Server
              }
            }
          '';
          virtualHosts = lib.mkMerge [
            {
              "*.${cfg.domain}" = {
                extraConfig = "abort";
                serverAliases = [ cfg.domain ];
                useACMEHost = cfg.domain;
              };
              "w.${cfg.domain}" = {
                extraConfig = "reverse_proxy localhost:${toString config.services.whoami.port}";
                useACMEHost = cfg.domain;
              };
            }
            (lib.mkIf config.services.tailscale.enable {
              "*.${cfg.tsDomain}" = {
                extraConfig = "abort";
                serverAliases = [ cfg.tsDomain ];
                useACMEHost = cfg.tsDomain;
              };
              "w.${cfg.tsDomain}" = {
                extraConfig = "reverse_proxy localhost:${toString config.services.whoami.port}";
                useACMEHost = cfg.tsDomain;
              };
            })
          ];
        };
        whoami.enable = true;
      };
    })
  ];
}
