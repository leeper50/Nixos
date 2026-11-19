{
  config,
  globals,
  lib,
  localLib,
  secrets,
  ...
}:
let
  port = 8222;
in
{
  options.local.vaultwarden = {
    enable = lib.mkEnableOption "vaultwarden";
  };
  config = lib.mkMerge [
    (lib.mkIf config.local.vaultwarden.enable {
      age.secrets."vaultwarden_env.age".file = "${secrets}/vaultwarden_env.age";
      # The database lives in postgresql, which has its own dump backup.
      local.restic.backups.services = {
        exclude = [ "/var/lib/vaultwarden/icon_cache" ];
        paths = [ "/var/lib/vaultwarden" ];
        user = "root";
      };
      services.vaultwarden = {
        config = {
          DOMAIN = "https://vault.dellhplaptop.xyz";
          SIGNUPS_ALLOWED = false;
          SMTP_HOST = "smtp.mailbox.org";
          SMTP_PORT = 587;
          SMTP_SECURITY = "starttls";
          SMTP_FROM = globals.primaryEmail;
          SMTP_FROM_NAME = "mailbox.org Vaultwarden server";
          SMTP_USERNAME = globals.primaryEmail;
          IP_HEADER = "X-Real-IP";
          ROCKET_ADDRESS = lib.mkDefault "127.0.0.1";
          ROCKET_PORT = port;
        };
        enable = true;
        # vaultwarden_env.age should contain these variables:
        # ADMIN_TOKEN   = `openssl rand -hex 24`
        # DATABASE_URL  = `postgresql://vaultwarden:password@nas:5432/vaultwarden`
        # SMTP_PASSWORD = `blah`
        dbBackend = "postgresql";
        environmentFile = config.age.secrets."vaultwarden_env.age".path;
      };
    })
    (lib.mkIf (config.local.vaultwarden.enable && config.services.caddy.enable) {
      services.caddy.virtualHosts = localLib.mkCaddyVirtualHosts {
        vault = {
          # The admin panel is LAN-only
          extraConfig = ''
            @remote_admin {
              path /admin /admin/*
              not client_ip ${lib.strings.join " " globals.networking.lan.subnets}
            }
            abort @remote_admin
            reverse_proxy 127.0.0.1:${toString port} {
              header_up X-Real-IP {client_ip}
            }
          '';
          ipFilter = "friendly_ips";
        };
      };
    })
    # Serve over docker reverse proxy.
    (lib.mkIf (config.local.vaultwarden.enable && config.virtualisation.docker.enable) {
      networking.firewall = localLib.mkFirewallRules {
        service = "vaultwarden";
        sources = globals.networking.docker.subnets;
        tcpPorts = [ port ];
      };
      services.vaultwarden.config.ROCKET_ADDRESS = "::";
    })
  ];
}
