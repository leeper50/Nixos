{
  config,
  lib,
  nur,
  pkgs,
  ...
}:
{
  imports = [
    nur.modules.nixos.default
    ./hardware-configuration.nix
    ../../nixos/services/power.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "laptop";
    networkmanager.enable = true;
  };
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  security.rtkit.enable = true;
  services = {
    displayManager.sddm.enable = true;
    xserver.enable = true;
    printing.enable = true;
    power-profiles-daemon.enable = true;
    pulseaudio.enable = false;
    pipewire = {
      alsa.enable = true;
      alsa.support32Bit = true;
      enable = true;
      pulse.enable = true;
    };
  };

  system.stateVersion = "26.05";

}
