{ config, globals, ... }:
let
  cfg = config.local.syncthing;
  home = cfg.home;
in
{
  imports = [
    ../home/syncthing.nix
  ];
  networking.firewall.allowedTCPPorts = [ 8384 ];
  services.syncthing = {
    configDir = "${home}/Sync/.config/syncthing";
    databaseDir = "${home}/Sync/.config/syncthing";
    dataDir = "${home}/Sync";
    group = globals.username;
    openDefaultPorts = true;
    user = globals.username;
  };
}
