{ config, globals, ... }:
{
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
  services.rustfs = {
    enable = true;
    environmentFile = config.age.secrets."restic_rustfs_env.age".path;
    settings = {
      RUSTFS_REGION = "nas";
      RUSTFS_VOLUMES = "/mnt/data/rustfs";
    };
  };
}
