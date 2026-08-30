{
  config,
  globals,
  lib,
  ...
}:
let
  cfg = config.local.nginx;
in
{
  options.local.nginx = {
    enable = lib.mkEnableOption "nginx";
  };
  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
    security.acme = {
      acceptTerms = true;
      defaults.email = globals.primaryEmail;
      certs = {
        ${globals.domain} = {
          dnsProvider = "porkbun";
          dnsPropagationCheck = true;
          environmentFile = config.age.secrets."porkbun_dns_api_token.age".path;
          extraDomainNames = [ "*.${globals.domain}" ];
          group = "nginx";
        };
      };
    };
    services.nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      serverTokens = false;
      appendHttpConfig = ''
        limit_req_zone $binary_remote_addr zone=req_limit_per_ip:10m rate=10r/s;
        limit_req zone=req_limit_per_ip burst=20 nodelay;
        add_header X-Content-Type-Options nosniff always;
        add_header X-Frame-Options SAMEORIGIN always;
        add_header Referrer-Policy strict-origin-when-cross-origin always;
        add_header Permissions-Policy "camera=(), microphone=(), geolocation=()" always;
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
      '';
      virtualHosts = {
        "_" = {
          default = true;
          extraConfig = ''
            return 444;
          '';
        };
      };
    };
    services.fail2ban.jails = {
      nginx-bad-request = { };
      nginx-botsearch = { };
      nginx-forbidden = { };
      nginx-limit-req = { };
    };
  };
}
