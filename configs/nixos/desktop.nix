# Shared settings for the GUI machines.
{
  config,
  disko,
  lib,
  nur,
  secrets,
  ...
}:
{
  imports = [
    ../home/packages
    ./nix-ld.nix
    ./power.nix
    ./syncthing.nix
    ./u2f.nix
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
  home-manager.users.walter.local.browsers = {
    chromium.enable = lib.mkDefault true;
    firefox.enable = lib.mkDefault true;
    librewolf.enable = lib.mkDefault true;
  };
  local = {
    caddy.enable = lib.mkDefault true;
    games.emulators.enable = lib.mkDefault true;
    local = true;
    mounts = {
      media = lib.mkDefault true;
      user = lib.mkDefault true;
    };
    nix-ld.enable = lib.mkDefault true;
    packages = {
      cream-linux.enable = lib.mkDefault true;
      elegoo-slicer.enable = lib.mkDefault true;
      ollama.enable = lib.mkDefault true;
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
  security.rtkit.enable = true;
  services = {
    btrfs.autoScrub.enable = true;
    fstrim.enable = true;
    power-profiles-daemon.enable = true;
    upower.enable = true;
  };
}
