{
  config,
  globals,
  lib,
  ...
}:
let
  cfg = config.local.fail2ban;
  ipIgnoreList = [
    "::1"
    "127.0.0.1/8"
    "162.233.151.119/32"
    globals.networking.docker.fixedv6Subnet
    globals.networking.docker.ipv4Subnet
    globals.networking.docker.ipv6Subnet
    globals.networking.ipv6.lanSubnet
  ]
  ++ globals.networking.lan;
  caddyLogDir = config.services.caddy.logDir;
  caddyLine = ''^\{"level":"[^"]*",[^{]*"logger":"http\.log\.access[^"]*","msg":"handled request","request":\{"remote_ip":"<HOST>",.*'';
  caddyJail = logpath: filter: settings: {
    filter.Definition = {
      failregex = caddyLine + filter;
      datepattern = ''"ts":{EPOCH}'';
    };
    settings = {
      enabled = true;
      backend = "auto";
      inherit logpath;
      action = "nftables-allports[protocol=all]";
      ignoreip = lib.concatStringsSep " " ipIgnoreList;
    }
    // settings;
  };
  traefikAccessLog = "/var/log/traefik/access.log";
  traefikLine = ''^\{"ClientAddr":"[^"]*","ClientHost":"<HOST>",.*'';
  traefikJail = filter: settings: {
    filter.Definition = {
      failregex = traefikLine + filter;
      datepattern = ''"time":"%%Y-%%m-%%dT%%H:%%M:%%S%%z"'';
    };
    settings = {
      enabled = true;
      backend = "auto";
      logpath = traefikAccessLog;
      action = "nftables-allports[chain=f2b-traefik, chain_hook=prerouting, chain_priority=-150, blocktype=drop, protocol=all]";
      ignoreip = lib.concatStringsSep " " ipIgnoreList;
    }
    // settings;
  };
in
{
  options.local.fail2ban = {
    jails.caddy.enable = lib.mkEnableOption "caddy jails";
    jails.traefik.enable = lib.mkEnableOption "traefik jails";
  };
  config = lib.mkMerge [
    {
      services.fail2ban = {
        bantime = "24h";
        bantime-increment.enable = true;
        enable = true;
        ignoreIP = ipIgnoreList;
      };
    }
    (lib.mkIf cfg.jails.caddy.enable {
      services.fail2ban.jails = {
        # 401/403 codes
        caddy-auth = caddyJail "${caddyLogDir}/access-*.log" ''"status":40[13],'' {
          findtime = "10m";
          maxretry = 20;
        };
        # 404s codes on unmatched routes
        caddy-scan = caddyJail "${caddyLogDir}/access-[*].*.log" ''"status":0,'' {
          findtime = "1d";
          maxretry = 3;
        };
      };
    })
    (lib.mkIf cfg.jails.traefik.enable {
      services.fail2ban.jails = {
        # 401/403 codes
        traefik-auth = traefikJail ''"DownstreamStatus":40[13],'' {
          findtime = "10m";
          maxretry = 20;
        };
        # 404s codes on unmatched routes
        traefik-scan = traefikJail ''"DownstreamStatus":404,.*"OriginStatus":0,'' {
          findtime = "1d";
          maxretry = 3;
        };
      };
      services.logrotate.settings.traefik = {
        files = traefikAccessLog;
        compress = true;
        copytruncate = true;
        frequency = "weekly";
        missingok = true;
        notifempty = true;
        rotate = 4;
      };
    })
  ];
}
