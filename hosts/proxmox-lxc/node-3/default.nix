{ pkgs, ... }:
let
  rootDir = ../../..;
in
{
  imports = map (p: rootDir + p) [
    /configs/nixos/caddy.nix
  ];
  environment.systemPackages = with pkgs; [
    intel-gpu-tools
  ];
  local = {
    caddy.enable = true;
    docker = {
      komodo = {
        coreIP = "10.0.0.21";
        periphery.enable = true;
      };
      swarm = {
        labels = [ "slow" ];
        managerIP = "10.0.0.21";
      };
    };
  };
  networking = {
    hostName = "node-3";
    interfaces.eth0 = {
      ipv4.addresses = [
        {
          address = "10.0.0.23";
          prefixLength = 8;
        }
      ];
      ipv6.addresses = [
        {
          address = "2600:1702:58c1:9acf::23";
          prefixLength = 64;
        }
      ];
    };
  };
  system.stateVersion = "25.11";
}
