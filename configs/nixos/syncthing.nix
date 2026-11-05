{
  config,
  globals,
  lib,
  localLib,
  ...
}:
{
  imports = [
    ../home/syncthing.nix
  ];
  config = lib.mkMerge [
    {
      networking.firewall = localLib.mkFirewallRules {
        service = "syncthing";
        sources = globals.networking.lan;
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
        configDir = "${config.local.syncthing.home}/Sync/.config/syncthing";
        databaseDir = "${config.local.syncthing.home}/Sync/.config/syncthing";
        dataDir = "${config.local.syncthing.home}/Sync";
        group = "walter";
        user = "walter";
      };
    }
    (lib.mkIf config.services.caddy.enable {
      services.caddy.virtualHosts = localLib.mkCaddyVirtualHosts {
        sync = "reverse_proxy 127.0.0.1:8384";
      };
    })
  ];
}
