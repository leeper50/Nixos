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
}
