{ lib, modulesPath, ... }:
let
  rootDir = ../..;
in
{
  imports =
    map (p: rootDir + p) [
      /home/profiles/cli_nixos.nix
      /nixos
      /nixos/configs/local_networking.nix
      /nixos/services/avahi.nix
      /nixos/services/docker
      /nixos/services/docker/komodo.nix
      /nixos/services/docker/swarm.nix
      /nixos/services/keepalived.nix
      /nixos/services/power.nix
    ]
    ++ [
      (modulesPath + "/virtualisation/proxmox-lxc.nix")
    ];
  networking = {
    defaultGateway = {
      interface = "eth0";
    };
    networkmanager.enable = lib.mkForce false;
  };
  proxmoxLXC.manageHostName = true;
  users.users.root.initialPassword = "nixos";
}
