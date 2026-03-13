{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking = {
    hostName = "gk55";
    interfaces.enp1s0 = {
      ipv4.addresses = [
        {
          address = "10.0.0.20";
          prefixLength = 8;
        }
      ];
    };
  };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    btrfs-progs
    busybox
    curl
    ethtool
    git
    iperf
    samba
  ];

  system.stateVersion = "25.11";
}
