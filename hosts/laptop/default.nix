{
  globals,
  nur,
  pkgs,
  ...
}:
let
  rootDir = ../..;
in
{
  imports =
    map (p: rootDir + p) [
      /home/profiles/gui_nixos.nix
      /home/packages
      /nixos
      /nixos/configs/mounts.nix
      /nixos/configs/networking.nix
      /nixos/services/avahi.nix
      /nixos/services/power.nix
      /restic
      /syncthing/nixos.nix
    ]
    ++ [
      ./gpu.nix
      ./hardware-configuration.nix
      nur.modules.nixos.default
    ];
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
  };
  local = {
    mounts = {
      media = true;
      user = true;
    };
    networking.local = true;
    packages = {
      cream-linux.enable = true;
      elegoo-slicer.enable = true;
      ollama.enable = true;
      waifu2x.enable = true;
    };
    restic.backups.home = {
      exclude = [
        "/home/${globals.username}/.cache"
        "/home/${globals.username}/.local/share/Steam"
        "/home/${globals.username}/.local/share/Trash"
        "/home/${globals.username}/.steam"
        "/home/${globals.username}/Games"
        "/home/${globals.username}/Nas"
        "/home/${globals.username}/Sync/Retroarch"
      ];
      paths = [
        "/home/${globals.username}"
      ];
    };
    syncthing.folders = {
      "Desktops".enable = true;
      "Downloads".enable = true;
      "FreeTube".enable = true;
      "GlobalShare".enable = true;
      "Notes".enable = true;
      "Tablet".enable = true;
    };
  };
  networking.hostName = "laptop";
  programs.nix-ld.enable = true;
  security.rtkit.enable = true;
  services = {
    asusd = {
      asusdConfig.source = ./asusd.ron;
      enable = true;
    };
    power-profiles-daemon.enable = true;
  };
  system.stateVersion = "26.05";
  users.users.${globals.username} = {
    extraGroups = [ "libvirtd" ];
    packages = with pkgs; [
      asusctl
      uv
      virt-manager
    ];
  };
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
  };
}
