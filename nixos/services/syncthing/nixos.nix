{ lib, config, ... }:
let
  cfg = config.local.syncthing;
  home = cfg.home;
in
{
  imports = [
    ./base.nix
  ];
  networking.firewall.allowedTCPPorts = [ 8384 ];
  services.syncthing = {
    configDir = "${home}/Sync/.config/syncthing";
    databaseDir = "${home}/Sync/.config/syncthing";
    dataDir = "${home}/Sync";
    group = "users";
    openDefaultPorts = true;
    user = "walter";
  };
}
