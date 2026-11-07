{
  config,
  disko,
  globals,
  lib,
  nur,
  pkgs,
  secrets,
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
      /configs/nixos/u2f.nix
    ]
    ++ [
      ./disk-config.nix
      ./hardware-configuration.nix
      disko.nixosModules.disko
      nur.modules.nixos.default
    ];
  age.secrets."wifi_home_env.age".file = "${secrets}/wifi_home_env.age";
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
  home-manager.users = {
    walter = {
      wayland.windowManager.hyprland.extraLuaFiles."monitors.lua" = {
        autoLoad = true;
        content = ''
          hl.monitor({
            mode = "highrr",
            output = "DP-1",
            supports_hdr = -1
          })
          hl.monitor({
            mode = "highrr",
            output = "HDMI-A-1",
            supports_hdr = -1
          })
          hl.workspace_rule({monitor = "DP-1", workspace = "1"})
          hl.workspace_rule({monitor = "DP-1", workspace = "3"})
          hl.workspace_rule({monitor = "HDMI-A-1", workspace = "2"})
          hl.workspace_rule({monitor = "HDMI-A-1", workspace = "4"})
        '';
      };
      local = {
        browsers = {
          brave.enable = true;
          firefox.enable = true;
          librewolf.enable = true;
        };
      };
    };
  };
  local = {
    games.emulators.enable = true;
    local = true;
    packages = {
      cream-linux.enable = true;
      elegoo-slicer.enable = true;
      ollama = {
        context_length = 32768;
        enable = true;
      };
      rimsort.enable = true;
      surge.enable = true;
      waifu2x.enable = true;
    };
    restic.backups.home = {
      exclude = [
        ".local/share/Steam"
        ".local/share/Trash"
        ".ollama"
        ".steam"
        "*cache*"
        "Games"
        "Nas"
        "Sync/Retroarch"
        "Temp"
      ];
      paths = [
        "/home"
      ];
      targets = [
        "nas"
      ];
      user = "root";
    };
    u2f.enable = true;
    users = {
      carrie.enable = true;
      david.enable = true;
    };
  };
  networking = {
    defaultGateway6.interface = "enp1s0";
    interfaces.enp1s0 = {
      ipv4.addresses = [
        {
          address = globals.networking.hosts.${config.networking.hostName}.ipv4;
          prefixLength = lib.toIntBase10 globals.networking.ipv4.subnetMask;
        }
      ];
      ipv6.addresses = [
        {
          address = globals.networking.hosts.${config.networking.hostName}.ipv6;
          prefixLength = lib.toIntBase10 globals.networking.ipv6.subnetMask;
        }
      ];
    };
    networkmanager = {
      unmanaged = [ "enp1s0" ];
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
            ip6-privacy = "0";
          };
        };
      };
    };
  };
  nix.settings.allowed-users = [
    "root"
  ]
  ++ lib.attrNames (lib.filterAttrs (_: user: user.enable) config.local.users);
  programs.nix-ld.enable = true;
  security.rtkit.enable = true;
  services = {
    btrfs.autoScrub.enable = true;
    flatpak.enable = lib.mkForce false;
    fstrim.enable = true;
    openssh.settings = {
      AllowUsers = [
        "root"
        "walter"
      ];
      KbdInteractiveAuthentication = lib.mkForce false;
    };
    power-profiles-daemon.enable = true;
    printing.drivers = with pkgs; [
      gutenprint
      hplip
    ];
    upower.enable = true;
  };
  system.stateVersion = "26.05";
}
