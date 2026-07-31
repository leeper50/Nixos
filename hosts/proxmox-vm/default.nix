{ ... }:
{
  imports = [
    ../../nixos/configs/networking.nix
    ./disk-config.nix
    ./hardware-configuration.nix
  ];
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 500;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
  systemd.services.qemu-guest-agent.serviceConfig.Restart = "always";
}
