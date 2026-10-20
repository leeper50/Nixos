{
  config,
  disko,
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
  home-manager.users.walter.local.browsers = {
    brave.enable = true;
    firefox.enable = true;
    librewolf.enable = true;
  };
  local = {
    beszel.agent.enable = true;
    caddy.enable = true;
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
      surge.enable = true;
      waifu2x.enable = true;
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
  };
  age.secrets."wifi_home_env.age".file = rootDir + /secrets/wifi_home_env.age;
  networking.networkmanager = {
    ensureProfiles = {
      environmentFiles = [ config.age.secrets."wifi_home_env.age".path ];
      profiles.home = {
        connection = {
          id = "home";
          type = "wifi";
        };
        wifi = {
          mode = "infrastructure";
          ssid = "$WIFI_SSID";
        };
        wifi-security = {
          key-mgmt = "sae";
          psk = "$WIFI_PASSWORD";
        };
        ipv4.method = "auto";
        ipv6 = {
          method = "auto";
          token = "::71";
          ip6-privacy = "0";
        };
      };
    };
  };
  programs.nix-ld.enable = true;
  security.rtkit.enable = true;
  services = {
    asusd = {
      asusdConfig.source = ./asusd.ron;
      enable = true;
    };
    btrfs.autoScrub.enable = true;
    fstrim.enable = true;
    logind.settings.Login = {
      HandleLidSwitch = "hibernate";
      HandleLidSwitchDocked = "ignore";
      HandleLidSwitchExternalPower = "ignore";
      HandlePowerKey = "ignore";
    };
    power-profiles-daemon.enable = true;
    upower.enable = true;
  };
  system.stateVersion = "26.05";
  users.users.walter = {
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
