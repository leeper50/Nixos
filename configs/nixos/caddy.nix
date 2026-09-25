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
          virtualHosts."w.${cfg.domain}" = {
            extraConfig = "reverse_proxy localhost:${toString config.services.whoami.port}";
            useACMEHost = cfg.domain;
          };
        };
        whoami.enable = true;
      };
    })
  ];
}
