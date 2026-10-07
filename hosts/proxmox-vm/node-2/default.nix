{ globals, pkgs, ... }:
let
  rootDir = ../../..;
in
{
  imports = map (p: rootDir + p) [
    /configs/nixos/jellyfin.nix
  ];
  environment.systemPackages = with pkgs; [
    nvtopPackages.intel
  ];
  hardware.enableRedistributableFirmware = true;
  local = {
    caddy.enable = true;
    docker = {
      komodo = {
        coreIP = globals.networking.hosts.node-1.ipv4;
        periphery.enable = true;
      };
      swarm = {
        labels = [ "intel_gpu" ];
        managerIP = globals.networking.hosts.node-1.ipv4;
      };
    };
    jellyfin.enable = true;
  };
  system.stateVersion = "25.11";
}
