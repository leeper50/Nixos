{ config, ... }:
{
  networking.firewall.extraInputRules = ''
    ip saddr 10.0.0.0/8 tcp dport { 9000, 9001 } accept
    ip6 saddr 2600:1702:58c1:9acf::/64 tcp dport { 9000, 9001 } accept
  '';
  services.rustfs = {
    enable = true;
    environmentFile = config.age.secrets."restic_rustfs_env.age".path;
    settings = {
      RUSTFS_REGION = "nas";
      RUSTFS_VOLUMES = "/mnt/data/rustfs";
    };
  };
}
