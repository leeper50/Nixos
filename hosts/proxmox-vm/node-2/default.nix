{ globals, pkgs, ... }:
let
  rootDir = ../../..;
  homelab = rootDir + /configs/nixos/homelab;
in
{
  imports = map (p: homelab + p) [
    /forgejo.nix
    /jellyfin.nix
  ];
  environment.systemPackages = with pkgs; [
    nvtopPackages.intel
  ];
  hardware.enableRedistributableFirmware = true;
  local = {
    beszel.agent.intelGpu = true;
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
    forgejo = {
      runner = {
        enable = true;
        nixHost = true;
        uuid = "3e9af3ee-ad9b-48f9-a9ad-9349cf9629ea";
      };
      server.enable = true;
    };
    jellyfin.enable = true;
  };
  system.stateVersion = "25.11";
}
