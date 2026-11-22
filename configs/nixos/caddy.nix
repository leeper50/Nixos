{
  config,
  globals,
  lib,
  localLib,
  ...
}:
let
  localIps =
    globals.networking.lan.subnets
    ++ lib.optionals config.virtualisation.docker.enable globals.networking.docker.subnets;
  cfg = config.local.caddy;
  traefikIps = with globals.networking.lan.hosts.nas; [
    ipv4
    ipv6
  ];
in
{
  options.local.caddy = {
    domain = lib.mkOption {
      default = globals.domains.devicePrimary;
      type = lib.types.str;
    };
    enable = lib.mkEnableOption "caddy";
    traefikPassthrough = {
      enable = lib.mkEnableOption ''
        Serving Caddy behind Traefik on the same host. Traefik owns 80/443 and
        passes this host's domains through over TCP with the PROXY protocol, so
        Caddy still sees the client's address. Caddy listens on these ports,
        reachable only from the Docker subnets
      '';
      httpPort = lib.mkOption {
        default = 8080;
        type = lib.types.port;
      };
      httpsPort = lib.mkOption {
        default = 8443;
        type = lib.types.port;
      };
    };
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
        config.extraConfig = lib.mkIf config.local.caddy.enable (lib.mkBefore "import hardening");
      }
    );
  };
  config = lib.mkMerge [
    (lib.mkIf config.local.caddy.enable {
      local = {
        acme = {
          certs = {
            ${config.local.caddy.domain} = {
              group = "caddy";
              provider = config.local.caddy.provider;
              wildcard = true;
            };
          };
          enable = true;
        };
        fail2ban.jails.caddy.enable = true;
      };
      assertions = [
        {
          assertion = !cfg.traefikPassthrough.enable || config.virtualisation.docker.enable;
          message = "local.caddy.traefikPassthrough needs Traefik, which runs in Docker.";
        }
      ];
      networking.firewall =
        if cfg.traefikPassthrough.enable then
          localLib.mkFirewallRules {
            service = "caddy";
            sources = globals.networking.docker.subnets;
            tcpPorts = with cfg.traefikPassthrough; [
              httpPort
              httpsPort
            ];
          }
        else
          localLib.mkFirewallRules {
            service = "caddy";
            sources =
              if config.local.lan.enable then
                globals.networking.lan.subnets
                ++ lib.optionals config.virtualisation.docker.enable globals.networking.docker.subnets
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
          + lib.optionalString config.local.lan.enable ''
            (local_ips) {
              @local_ips client_ip ${lib.strings.join " " localIps}
            }
            (friendly_ips) {
              @friendly_ips client_ip ${
                lib.strings.join " " (
                  localIps
                  ++ [
                    globals.networking.lan.hosts.racknerd.ipv4
                    globals.networking.lan.hosts.servercheap.ipv4
                    globals.networking.lan.hosts.servercheap.ipv6
                  ]
                )
              }
            }
          '';
          globalConfig =
            lib.optionalString cfg.traefikPassthrough.enable ''
              http_port ${toString cfg.traefikPassthrough.httpPort}
              https_port ${toString cfg.traefikPassthrough.httpsPort}
            ''
            + lib.optionalString (config.local.lan.enable || cfg.traefikPassthrough.enable) ''
              servers {
                ${lib.optionalString config.local.lan.enable "trusted_proxies static ${
                  lib.strings.join " " (
                    traefikIps ++ lib.optionals cfg.traefikPassthrough.enable globals.networking.docker.subnets
                  )
                }"}
                ${lib.optionalString cfg.traefikPassthrough.enable ''
                  listener_wrappers {
                    proxy_protocol {
                      allow ${lib.strings.join " " globals.networking.docker.subnets}
                    }
                    tls
                  }
                ''}
              }
            '';
          virtualHosts = lib.mkMerge [
            {
              "*.${config.local.caddy.domain}" = {
                extraConfig = "abort";
                serverAliases = [ config.local.caddy.domain ];
                useACMEHost = config.local.caddy.domain;
              };
              "w.${config.local.caddy.domain}" = {
                extraConfig = "reverse_proxy localhost:${toString config.services.whoami.port}";
                useACMEHost = config.local.caddy.domain;
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
