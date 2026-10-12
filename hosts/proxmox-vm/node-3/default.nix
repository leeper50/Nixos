{ globals, ... }:
let
  rootDir = ../../..;
in
{
  imports = map (p: rootDir + p) [
    /configs/nixos/bentopdf.nix
    /configs/nixos/mealie.nix
    /configs/nixos/ntfy.nix
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
    mealie.enable = true;
    ntfy.enable = true;
  };
  system.stateVersion = "25.11";
}
