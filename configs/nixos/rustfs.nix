{
  config,
  globals,
  lib,
  ...
}:
let
  cfg = config.local.rustfs;
in
{
  options.local.rustfs = {
    enable = lib.mkEnableOption "rustfs";
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      networking.firewall = globals.mkFirewallRules {
        service = "rustfs";
        sources = [
          globals.networking.ipv4.lanSubnet
          globals.networking.ipv6.lanSubnet
        ];
        tcpPorts = [
          9000
          9001
        ];
      };
      systemd.services.rustfs.unitConfig.RequiresMountsFor = [ "/mnt/data" ];
      services.rustfs = {
        enable = true;
        environmentFile = config.age.secrets."restic_rustfs_env.age".path;
        settings = {
          RUSTFS_REGION = "nas";
          RUSTFS_VOLUMES = "/mnt/data/rustfs";
        };
      };
    })
    (lib.mkIf (cfg.enable && config.services.caddy.enable) {
      # Console on rustfs.*, S3 API on s3.*.
      services.caddy.virtualHosts = lib.listToAttrs (
        lib.concatMap
          (domain: [
            (lib.nameValuePair "rustfs.${domain}" {
              extraConfig = "reverse_proxy 127.0.0.1:9001";
              useACMEHost = domain;
            })
            (lib.nameValuePair "s3.${domain}" {
              extraConfig = "reverse_proxy 127.0.0.1:9000";
              useACMEHost = domain;
            })
          ])
          (
            [ config.local.caddy.domain ]
            ++ lib.optional config.services.tailscale.enable globals.domains.deviceTailnet
          )
      );
    })
  ];
}
