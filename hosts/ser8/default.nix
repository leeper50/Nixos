{ ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  networking = {
    hostName = "ser8";
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

  system.stateVersion = "25.11";
}
