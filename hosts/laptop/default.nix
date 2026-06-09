{ nur, ... }:
let
  rootDir = ../..;
in
{
  imports =
    map (p: rootDir + p) [
      /home/desktop/hyprland.nix
      /home/profiles/gui_nixos.nix
      /nixos
      /nixos/configs/local_networking.nix
      /nixos/desktop
      /nixos/services/avahi.nix
      /nixos/services/power.nix
    ]
    ++ [
      ./hardware-configuration.nix
      nur.modules.nixos.default
    ];
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
  };
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
    power-profiles-daemon.enable = true;
    printing.enable = true;
    pulseaudio.enable = false;
    pipewire = {
      alsa.enable = true;
      alsa.support32Bit = true;
      enable = true;
      pulse.enable = true;
    };
    xserver.enable = true;
  };
  system.stateVersion = "26.05";
}
