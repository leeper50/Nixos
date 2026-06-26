{ nur, pkgs, ... }:
let
  rootDir = ../..;
in
{
  imports =
    map (p: rootDir + p) [
      /home/profiles/gui_nixos.nix
      /nixos
      /nixos/configs/local_mounts.nix
      /nixos/configs/local_networking.nix
      /nixos/services/avahi.nix
      /nixos/services/power.nix
      /syncthing/laptop.nix
    ]
    ++ [
      ./gpu.nix
      ./waifu2x.nix
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
  programs.nix-ld.enable = true;
  security.rtkit.enable = true;
  services = {
    asusd.enable = true;
    power-profiles-daemon.enable = true;
  };
  system.stateVersion = "26.05";
  users.users.walter = {
    packages = with pkgs; [
      asusctl
      uv
    ];
  };
}
