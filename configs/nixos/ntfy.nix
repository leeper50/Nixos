{
  config,
  lib,
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
          attachment-cache-dir = "/var/cache/ntfy/attachments";
          auth-access = [
            "*:up*:write-only"
          ];
          auth-default-access = "deny-all";
          base-url = "https://n.${globals.domains.devicePrimary}";
          behind-proxy = true;
          cache-file = "/var/cache/ntfy/cache.db";
          enable-login = true;
          listen-http = ":${port}";
          require-login = true;
          smtp-sender-addr = "smtp.mailbox.org:587";
          smtp-sender-from = globals.primaryEmail;
        };
      };
    })
    (lib.mkIf config.services.caddy.enable {
      services.caddy.virtualHosts = lib.listToAttrs (
        map
          (
            domain:
            lib.nameValuePair "n.${domain}" {
              extraConfig = "reverse_proxy 127.0.0.1:${port}";
              useACMEHost = domain;
            }
          )
          (
            lib.optional config.local.local config.local.caddy.domain
            ++ lib.optional config.services.tailscale.enable globals.domains.deviceTailnet
          )
      );
    })
  ];
}
