{
  config,
  globals,
  lib,
  ...
}:
let
  cfg = config.local.syncthing;
  home = cfg.home;
in
{
  imports = [
    ../home/syncthing.nix
  ];
  config = lib.mkMerge [
    {
      networking.firewall = globals.mkFirewallRules {
        service = "syncthing";
        sources = [
          globals.networking.ipv4.lanSubnet
          globals.networking.ipv6.lanSubnet
        ];
        tcpPorts =
          if config.services.caddy.enable then
            [ 22000 ]
          else
            [
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
    (lib.mkIf config.services.caddy.enable {
      services.caddy.virtualHosts."sync.${config.local.caddy.domain}" = {
        extraConfig = "reverse_proxy localhost:8384";
        useACMEHost = config.local.caddy.domain;
      };
    })
  ];
}
