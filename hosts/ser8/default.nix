{
  config,
  globals,
  lib,
  pkgs,
  ...
}:
let
  rootDir = ../..;
in
{
  imports =
    map (p: rootDir + p) [
      /configs/nixos
      /configs/nixos/desktop.nix
    ]
    ++ [
      ./disk-config.nix
      ./hardware-configuration.nix
    ];
  home-manager.users.walter.wayland.windowManager.hyprland.extraLuaFiles."monitors.lua" = {
    autoLoad = true;
    content = ''
      hl.monitor({
        mode = "highrr",
        output = "DP-1",
        position = "auto-left",
        supports_hdr = -1,
        vrr = 2,
      })
      hl.monitor({
        mode = "highrr",
        output = "HDMI-A-1",
        position = "auto-right",
        supports_hdr = -1,
        vrr = 2,
      })
      hl.workspace_rule({monitor = "DP-1", workspace = "1"})
      hl.workspace_rule({monitor = "DP-1", workspace = "3"})
      hl.workspace_rule({monitor = "HDMI-A-1", workspace = "2"})
      hl.workspace_rule({monitor = "HDMI-A-1", workspace = "4"})
    '';
  };
  local = {
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
    networkmanager.unmanaged = [ "enp1s0" ];
  };
  nix.settings.allowed-users = [
    "root"
  ]
  ++ lib.attrNames (lib.filterAttrs (_: user: user.enable) config.local.users);
  services = {
    openssh.settings = {
      AllowUsers = [
        "root"
        "walter"
      ];
      KbdInteractiveAuthentication = lib.mkForce false;
    };
    printing.drivers = with pkgs; [
      gutenprint
      hplip
    ];
  };
  system.stateVersion = "26.05";
}
