{
  disko,
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
      /configs/home/packages
      /configs/nixos
      /configs/nixos/power.nix
      /configs/nixos/syncthing.nix
    ]
    ++ [
      ./disk-config.nix
      ./gpu.nix
      ./hardware-configuration.nix
      disko.nixosModules.disko
      nur.modules.nixos.default
    ];
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
  };
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General.Experimental = true;
      Policy.AutoEnable = true;
    };
  };
  home-manager.users.${globals.username}.local.browsers = {
    brave.enable = true;
    firefox.enable = true;
    librewolf.enable = true;
  };
  local = {
    local = true;
    mounts = {
      autoMount = true;
      media = true;
      user = true;
    };
    packages = {
      cream-linux.enable = true;
      elegoo-slicer.enable = true;
      ollama.enable = true;
      rimsort.enable = true;
      waifu2x.enable = true;
    };
    restic.backups.home = {
      exclude = [
        "*cache*"
        "/home/${globals.username}/.local/share/Steam"
        "/home/${globals.username}/.local/share/Trash"
        "/home/${globals.username}/.ollama"
        "/home/${globals.username}/.steam"
        "/home/${globals.username}/Games"
        "/home/${globals.username}/Nas"
        "/home/${globals.username}/Sync/Retroarch"
        "/home/${globals.username}/Temp"
      ];
      paths = [
        "/home/${globals.username}"
      ];
      targets = [
        "hetzner"
        "nas"
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
    blueman.enable = true;
    btrfs.autoScrub.enable = true;
    fstrim.enable = true;
    logind.settings.Login = {
      HandleLidSwitch = "hibernate";
      HandleLidSwitchDocked = "ignore";
      HandleLidSwitchExternalPower = "ignore";
      HandlePowerKey = "ignore";
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
