{
  config,
  lib,
  localLib,
  globals,
  ...
}:
let
  cfg = config.local.ntfy;
  port = "8081";
in
{
  options.local.ntfy = {
    enable = lib.mkEnableOption "ntfy";
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      services.ntfy-sh = {
        enable = true;
        environmentFile = config.age.secrets."ntfy_environment.age".path;
        # Setup user stuff in ntfy_environment.age & secrets.nix
        settings = {
          attachment-cache-dir = "/var/lib/ntfy-sh/attachments";
          auth-access = [
            "*:up*:write-only"
          ];
          auth-default-access = "deny-all";
          base-url = "https://n.${globals.domains.devicePrimary}";
          behind-proxy = true;
          cache-file = "/var/lib/ntfy-sh/cache.db";
          enable-login = true;
          listen-http = ":${port}";
          require-login = true;
          smtp-sender-addr = "smtp.mailbox.org:587";
          smtp-sender-from = globals.primaryEmail;
        };
      };
    })
    (lib.mkIf config.services.caddy.enable {
      services.caddy.virtualHosts = localLib.mkCaddyVirtualHosts {
        n = "reverse_proxy 127.0.0.1:${port}";
      };
    })
  ];
}
