# Shared settings for the GUI machines.
{
  config,
  disko,
  lib,
  nur,
  secrets,
  stylix,
  ...
}:
{
  imports = [
    ../home/games.nix
    ../home/packages
    ../home/stylix.nix
    ./desktop-sessions.nix
    ./nix-ld.nix
    ./power.nix
    ./sunshine.nix
    ./syncthing.nix
    ./u2f.nix
    disko.nixosModules.disko
    nur.modules.nixos.default
    stylix.nixosModules.stylix
  ];
  age.secrets = {
    "wifi_home_env.age".file = "${secrets}/wifi_home_env.age";
  }
  # walter's rclone remotes (configs/home/rclone.nix) read these.
  // lib.optionalAttrs config.local.users.walter.enable (
    lib.genAttrs
      [
        "restic_b2_env.age"
        "restic_password_file.age"
        "restic_rustfs_env.age"
        "user_walter_clear.age"
      ]
      (name: {
        file = "${secrets}/${name}";
        group = "walter";
        owner = "walter";
      })
  );
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
    chromium.enable = lib.mkDefault true;
    firefox.enable = lib.mkDefault true;
    librewolf.enable = lib.mkDefault true;
  };
  local = {
    caddy.enable = lib.mkDefault true;
    games.emulators.enable = lib.mkDefault true;
    lan.enable = true;
    mounts.shares = {
      media.enable = lib.mkDefault true;
      walter.enable = lib.mkDefault true;
    };
    nix-ld.enable = lib.mkDefault true;
    packages = {
      ai.ollama.enable = lib.mkDefault true;
      cream-linux.enable = lib.mkDefault true;
      elegoo-slicer.enable = lib.mkDefault true;
      rimsort.enable = lib.mkDefault true;
      surge.enable = lib.mkDefault true;
      waifu2x.enable = lib.mkDefault true;
    };
    u2f.enable = lib.mkDefault true;
  };
  networking.networkmanager.ensureProfiles = {
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
  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };
  services = {
    btrfs.autoScrub.enable = true;
    flatpak.enable = true;
    fstrim.enable = true;
    mullvad-vpn = {
      enable = true;
      gui.enable = true;
    };
    pcscd.enable = true;
    pipewire = {
      alsa.enable = true;
      alsa.support32Bit = true;
      enable = true;
      pulse.enable = true;
    };
    power-profiles-daemon.enable = true;
    printing.enable = true;
    pulseaudio.enable = false;
    udisks2.enable = true;
    upower.enable = true;
    xserver.enable = true;
  };
}
