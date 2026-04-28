{ ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];
  boot.kernel.sysctl = {
    "vm.vfs_cache_pressure" = 500;
    "vm.swappiness" = 10;
  };
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.enable = true;
  boot.loader.grub.useOSProber = true;
  networking = {
    hostName = "nas";
    interfaces.ens18 = {
      ipv4.addresses = [
        {
          address = "10.0.0.33";
          prefixLength = 8;
        }
      ];
    };
  };
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/mnt/data" ];
  };
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
  systemd.services.qemu-guest-agent.serviceConfig.Restart = "always";
  virtualisation.libvirtd.enable = true;
  system.stateVersion = "25.11";
}
