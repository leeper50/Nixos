{ lib, modulesPath, ... }:
let
  rootDir = ../..;
in
{
  imports =
    map (p: rootDir + p) [
      /home/profiles/cli_nixos.nix
      /nixos
      /nixos/configs/local_mounts.nix
      /nixos/configs/local_networking.nix
      /nixos/services/avahi.nix
      /nixos/services/blocky.nix
      /nixos/services/docker.nix
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
  systemd.network.wait-online.enable = false;
  users.users.root.initialPassword = "nixos";
}
