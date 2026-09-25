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
    tls.provider = lib.mkOption {
      default = "cloudflare";
      type = lib.types.enum [
        "cloudflare"
        "porkbun"
      ];
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
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
      security.acme = {
        acceptTerms = true;
        defaults.email = globals.primaryEmail;
        certs = {
          ${cfg.domain} = {
            dnsProvider = cfg.tls.provider;
            dnsPropagationCheck = true;
            dnsResolver = "1.1.1.1:53";
            environmentFile = config.age.secrets."acme_${cfg.tls.provider}.age".path;
            extraDomainNames = [ "*.${cfg.domain}" ];
            group = config.services.caddy.group;
          };
        };
      };
      systemd.services."acme-order-renew-${cfg.domain}".environment.LEGO_DISABLE_CNAME_SUPPORT = "true";
      services = {
        caddy = {
          email = globals.primaryEmail;
          enable = true;
          enableReload = true;
          environmentFile = config.age.secrets."acme_${cfg.tls.provider}.age".path;
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
