{ globals, ... }:
{
  imports = [
    ../../../configs/nixos/homelab/bentopdf.nix
    ../../../configs/nixos/homelab/gatus.nix
    ../../../configs/nixos/homelab/gotify.nix
    ../../../configs/nixos/homelab/mealie.nix
    ../../../configs/nixos/homelab/redlib.nix
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
    gatus.reporter.enable = true;
    gotify.enable = true;
    mealie.enable = true;
    redlib.enable = true;
  };
  system.stateVersion = "25.11";
}
