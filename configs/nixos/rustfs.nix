{
  config,
  globals,
  lib,
  localLib,
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
      networking.firewall = localLib.mkFirewallRules {
        service = "rustfs";
        sources = globals.networking.lan;
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
      services.caddy.virtualHosts = localLib.mkCaddyVirtualHosts {
        rustfs = "reverse_proxy 127.0.0.1:9001";
        s3 = "reverse_proxy 127.0.0.1:9000";
      };
    })
  ];
}
