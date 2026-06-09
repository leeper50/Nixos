{
  config,
  lib,
  nur,
  pkgs,
  stylix,
  ...
}:
{
  imports = [
    nur.modules.nixos.default
    ./hardware-configuration.nix
    ../../nixos/services/power.nix
    {
      home-manager = {
        sharedModules = [ stylix.homeModules.stylix ];
        users.walter = {
          imports = [
            ../../home/desktop
            ../../home/desktop
            ../../home/desktop/hyprland.nix
            ../../home/dev
            ../../home/firefox
          ];
        };
      };
    }
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
