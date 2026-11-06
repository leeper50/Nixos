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
      /configs/nixos
      /configs/nixos/power.nix
    ]
    ++ [
      ./disk-config.nix
      ./hardware-configuration.nix
      disko.nixosModules.disko
      nur.modules.nixos.default
    ];
  age.secrets = {
    "user_carrie_hash.age" = {
      file = "${secrets}/user_carrie_hash.age";
    };
    "user_david_hash.age" = {
      file = "${secrets}/user_david_hash.age";
    };
    "wifi_home_env.age".file = "${secrets}/wifi_home_env.age";
  };
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
  };
  environment.systemPackages = with pkgs; [
    bitwarden-desktop
    collabora-desktop
    rustdesk
    thunderbird
  ];
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General.Experimental = true;
      Policy.AutoEnable = true;
    };
  };
  local = {
    desktop = "plasma";
    local = true;
    restic.enable = false;
    restic.backups.home = {
      exclude = [
        "*cache*"
        ".local/share/Trash"
      ];
      paths = [
        "/home"
      ];
      targets = [
        "nas"
      ];
      user = "root";
    };
    walter.enable = false;
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
  nix.settings.allowed-users = [ "root" ];
  programs = {
    firefox = {
      enable = true;
      policies = {
        DisableTelemetry = true;
        ExtensionSettings."uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };
    nix-ld.enable = true;
  };
  security.rtkit.enable = true;
  services = {
    btrfs.autoScrub.enable = true;
    flatpak.enable = lib.mkForce false;
    fstrim.enable = true;
    openssh.settings = {
      AllowUsers = [ "root" ];
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
  users = {
    groups = {
      carrie = { };
      david = { };
    };
    users = {
      carrie = {
        description = "Carrie";
        extraGroups = [
          "audio"
          "input"
          "users"
          "video"
        ];
        group = "carrie";
        hashedPasswordFile = config.age.secrets."user_carrie_hash.age".path;
        isNormalUser = true;
      };
      david = {
        description = "David";
        extraGroups = [
          "audio"
          "input"
          "users"
          "video"
        ];
        group = "david";
        hashedPasswordFile = config.age.secrets."user_david_hash.age".path;
        isNormalUser = true;
      };
    };
  };
}
