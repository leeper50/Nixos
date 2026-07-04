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
      /restic
      /syncthing/laptop.nix
    ]
    ++ [
      ./gpu.nix
      ./hardware-configuration.nix
      ./waifu2x.nix
      nur.modules.nixos.default
    ];
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
  };
  local.restic.backups.home = {
    exclude = [
      "/home/walter/.cache"
      "/home/walter/.local/share/Steam"
      "/home/walter/.local/share/Trash"
      "/home/walter/Nas"
      "/home/walter/Sync/Retroarch"
    ];
    paths = [
      "/home/walter"
    ];
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
