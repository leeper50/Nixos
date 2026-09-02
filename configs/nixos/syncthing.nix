{ config, globals, ... }:
let
  cfg = config.local.syncthing;
  home = cfg.home;
in
{
  imports = [
    ../home/syncthing.nix
  ];
  networking.firewall = globals.mkFirewallRules {
    service = "syncthing";
    sources = [
      globals.networking.ipv4.lanSubnet
      globals.networking.ipv6.lanSubnet
    ];
    tcpPorts = [
      8384
      22000
    ];
    udpPorts = [
      22000
      21027
    ];
  };
  services.syncthing = {
    configDir = "${home}/Sync/.config/syncthing";
    databaseDir = "${home}/Sync/.config/syncthing";
    dataDir = "${home}/Sync";
    group = globals.username;
    user = globals.username;
  };
}
