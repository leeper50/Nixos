{
  config,
  globals,
  lib,
  ...
}:
{
  imports = [
    ../../configs/nixos
    ../../configs/nixos/desktop.nix
    ./disk-config.nix
    ./hardware-configuration.nix
  ];
  home-manager.users.walter.programs.plasma = {
    kscreenlocker.lockOnResume = false;
    powerdevil.AC = {
      autoSuspend = {
        action = lib.mkForce "sleep";
        idleTimeout = 600;
      };
      powerProfile = lib.mkForce "performance";
    };
  };
  local = {
    mounts = {
      media = false;
      user = false;
    };
    packages.ollama.context_length = 32768;
    sunshine.enable = true;
    users.walter.desktop = "plasma";
  };
  networking = {
    defaultGateway6.interface = "enp4s0";
    interfaces.enp4s0 = {
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
      # Wake-on-LAN by magic packet.
      wakeOnLan.enable = true;
    };
    networkmanager = {
      ensureProfiles.profiles.home.ipv6.token = "::31";
      # Prevent NetworkManager from removing static ips.
      unmanaged = [ "enp4s0" ];
    };
  };
  # USB autosuspend drops controllers.
  powerManagement.powertop.enable = false;
  programs = {
    gamemode.enable = true;
    gamescope.enable = true;
  };
  services = {
    sunshine.settings = {
      adapter_name = "/dev/dri/renderD128";
      encoder = "vaapi";
      sunshine_name = "gamehost";
    };
  };
  system.stateVersion = "26.11";
  systemd = {
    # No resume device is set up for the btrfs swapfile.
    targets = {
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };
  };
}
