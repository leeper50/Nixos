{ pkgs, ... }:
let
  rootDir = ../../..;
in
{
  imports = map (p: rootDir + p) [
    /configs/nixos/caddy.nix
    /configs/nixos/jellyfin.nix
  ];
  environment.systemPackages = with pkgs; [
    intel-gpu-tools
  ];
  users.groups = {
    host-render = {
      gid = 993;
      members = [ "jellyfin" ];
    };
    resolvconf.gid = 399;
  };
  local = {
    caddy.enable = true;
    docker = {
      komodo = {
        coreIP = "10.0.0.21";
        periphery.enable = true;
      };
      swarm = {
        labels = [ "intel_gpu" ];
        managerIP = "10.0.0.21";
      };
    };
    jellyfin.enable = true;
  };
  networking = {
    hostName = "node-2";
    interfaces.eth0 = {
      ipv4.addresses = [
        {
          address = "10.0.0.22";
          prefixLength = 8;
        }
      ];
      ipv6.addresses = [
        {
          address = "2600:1702:58c1:9acf::22";
          prefixLength = 64;
        }
      ];
    };
  };
  system.stateVersion = "25.11";
}
