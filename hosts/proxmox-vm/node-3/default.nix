{ globals, ... }:
let
  rootDir = ../../..;
in
{
  imports = map (p: rootDir + p) [
    /configs/nixos/bentopdf.nix
    /configs/nixos/gotify.nix
    /configs/nixos/mealie.nix
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
