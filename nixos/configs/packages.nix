{ pkgs, ... }:
{
  boot.kernelPackages = pkgs.linuxPackages_latest;
  environment.systemPackages = with pkgs; [
    btrfs-progs
    busybox
    curl
    ethtool
    git
    iperf
    ncdu
    rclone
    rsync
  ];
  services = {
    tailscale.enable = true;
  };
}
