{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
  systemd.services.qemu-guest-agent.serviceConfig.Restart = "always";
  virtualisation.libvirtd.enable = true;

  networking = {
    hostName = "node-1";
    interfaces.ens18 = {
      ipv4.addresses = [
        {
          address = "10.0.0.21";
          prefixLength = 8;
        }
      ];
    };
  };

  system.stateVersion = "25.11";
}
