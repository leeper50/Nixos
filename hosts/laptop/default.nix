{ pkgs, ... }:
{
  imports = [
    ../../configs/nixos
    ../../configs/nixos/desktop.nix
    ./disk-config.nix
    ./gpu.nix
    ./hardware-configuration.nix
  ];
  local = {
    mounts = {
      autoMount = true;
      tailnet = true;
    };
    restic.backups.home = {
      exclude = [
        "*cache*"
      ]
      ++ map (s: "/home/walter/" + s) [
        ".local/share/Steam"
        ".local/share/Trash"
        ".ollama"
        ".steam"
        "Games"
        "Nas"
        "Sync/Retroarch"
        "Temp"
      ];
      paths = [
        "/home/walter"
      ];
      targets = [
        "nas"
      ];
    };
    syncthing.enable = true;
  };
  networking.networkmanager.ensureProfiles.profiles.home.ipv6.token = "::71";
  services = {
    asusd = {
      asusdConfig.source = ./asusd.ron;
      enable = true;
    };
    logind.settings.Login = {
      HandleLidSwitch = "hibernate";
      HandleLidSwitchDocked = "ignore";
      HandleLidSwitchExternalPower = "ignore";
      HandlePowerKey = "ignore";
    };
  };
  system.stateVersion = "26.05";
  users.users.walter = {
    extraGroups = [ "libvirtd" ];
    packages = with pkgs; [
      asusctl
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
