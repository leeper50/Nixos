{
  config,
  globals,
  lib,
  localLib,
  ...
}:
let
  cfg = config.local.caddy;
in
{
  options.local.caddy = {
    domain = lib.mkOption {
      default = globals.domains.devicePrimary;
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
      local = {
        acme = {
          certs = {
            ${cfg.domain} = {
              group = "caddy";
              provider = cfg.provider;
              wildcard = true;
            };
          };
          enable = true;
        };
        fail2ban.jails.caddy.enable = true;
      };
      networking.firewall = localLib.mkFirewallRules {
        service = "caddy";
        sources =
          if config.local.local then
            globals.networking.lan
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
          ''
          + lib.optionalString config.local.local ''
            (local_ips) {
              @local_ips client_ip ${lib.strings.join " " globals.networking.lan}
            }
            (friendly_ips) {
              @friendly_ips client_ip ${
                lib.strings.join " " (
                  globals.networking.lan
                  ++ [
                    globals.networking.hosts.racknerd.ipv4
                    globals.networking.hosts.servercheap.ipv4
                    globals.networking.hosts.servercheap.ipv6
                  ]
                )
              }
            }
          '';
          globalConfig = lib.optionalString config.local.local ''
            servers {
              trusted_proxies static ${
                lib.strings.join " " [
                  globals.networking.hosts.node-1.ipv4
                  globals.networking.hosts.node-1.ipv6
                ]
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
              "*.${globals.domains.deviceTailnet}" = {
                extraConfig = "abort";
                serverAliases = [ globals.domains.deviceTailnet ];
                useACMEHost = globals.domains.deviceTailnet;
              };
              "w.${globals.domains.deviceTailnet}" = {
                extraConfig = "reverse_proxy localhost:${toString config.services.whoami.port}";
                useACMEHost = globals.domains.deviceTailnet;
              };
            })
          ];
        };
        whoami.enable = true;
      };
    })
  ];
}
