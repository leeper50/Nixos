{ ... }:
{
  imports = [
    ../../nixos/configs/networking.nix
    ./hardware-configuration.nix
    ./disk-config.nix
  ];
  boot.kernel.sysctl = {
    "vm.vfs_cache_pressure" = 500;
    "vm.swappiness" = 10;
  };
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
  systemd.services.qemu-guest-agent.serviceConfig.Restart = "always";
  virtualisation.libvirtd.enable = true;
}
