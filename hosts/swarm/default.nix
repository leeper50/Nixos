{ ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  services.spice-vdagentd.enable = true;
  services.qemuGuest.enable = true;
  virtualisation.libvirtd.enable = true;
  systemd.services.qemu-guest-agent.serviceConfig.Restart = "always";

  networking = {
    hostName = "swarm";
    interfaces.ens18 = {
      ipv4.addresses = [
        {
          address = "10.0.0.34";
          prefixLength = 8;
        }
      ];
    };
  };

  system.stateVersion = "25.11";
}
