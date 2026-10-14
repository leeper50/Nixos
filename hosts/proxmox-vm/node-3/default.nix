{ globals, ... }:
let
  rootDir = ../../..;
  homelab = rootDir + /configs/nixos/homelab;
in
{
  imports = map (p: homelab + p) [
    /bentopdf.nix
    /gotify.nix
    /mealie.nix
  ];
  local = {
    bentopdf.enable = true;
    caddy.enable = true;
    docker = {
      komodo = {
        coreIP = globals.networking.hosts.node-1.ipv4;
        periphery.enable = true;
      };
      swarm = {
        labels = [ "slow" ];
        managerIP = globals.networking.hosts.node-1.ipv4;
      };
    };
    gotify.enable = true;
    mealie.enable = true;
  };
  system.stateVersion = "25.11";
}
