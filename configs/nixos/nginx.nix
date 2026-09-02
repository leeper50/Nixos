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
    domain = lib.mkOption {
      default = null;
      type = lib.types.nullOr lib.types.str;
    };
    enable = lib.mkEnableOption "nginx";
    tls.provider = lib.mkOption {
      default = null;
      type = lib.types.nullOr lib.types.str;
    };
  };
  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
    networking.firewall.allowedUDPPorts = [
      443
    ];
    security.acme = {
      acceptTerms = true;
      defaults.email = globals.primaryEmail;
      certs = {
        ${cfg.domain} = {
          dnsProvider = cfg.tls.provider;
          dnsPropagationCheck = true;
          environmentFile = config.age.secrets."acme_${cfg.tls.provider}.age".path;
          extraDomainNames = [ "*.${cfg.domain}" ];
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
        limit_req_zone $binary_remote_addr zone=req_limit_per_ip:10m rate=50r/s;
        limit_req zone=req_limit_per_ip burst=100;
        add_header X-Content-Type-Options nosniff always;
        add_header X-Frame-Options SAMEORIGIN always;
        add_header Referrer-Policy strict-origin-when-cross-origin always;
        add_header Permissions-Policy "camera=(), microphone=(), geolocation=()" always;
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
        add_header Alt-Svc 'h3=":443"; ma=86400' always;
      '';
      virtualHosts = {
        "_" = {
          addSSL = true;
          default = true;
          extraConfig = ''
            return 444;
          '';
          quic = true;
          reuseport = true;
          useACMEHost = cfg.domain;
        };
      };
    };
    services.fail2ban.jails = {
      nginx-bad-request.settings.backend = "auto";
      nginx-botsearch.settings = {
        backend = "auto";
        logpath = "/var/log/nginx/access.log\n            /var/log/nginx/error.log";
      };
      nginx-forbidden.settings.backend = "auto";
      nginx-limit-req.settings.backend = "auto";
    };
  };
}
