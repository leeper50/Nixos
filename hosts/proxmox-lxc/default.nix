{ lib, modulesPath, ... }:
let
  rootDir = ../..;
in
{
  imports =
    map (p: rootDir + p) [
      /home/profiles/cli_nixos.nix
      /nixos
      /nixos/configs/mounts.nix
      /nixos/configs/networking.nix
      /nixos/services/adguardhome.nix
      /nixos/services/avahi.nix
      /nixos/services/beszel.nix
      /nixos/services/docker.nix
      /nixos/services/keepalived.nix
      /nixos/services/power.nix
    ]
    ++ [
      (modulesPath + "/virtualisation/proxmox-lxc.nix")
    ];
  local = {
    networking.local = true;
    docker = {
      komodo = {
        coreIP = "10.0.0.60";
        enable = true;
      };
    };
  };
  networking = {
    defaultGateway.interface = "eth0";
    defaultGateway6.interface = "eth0";
    networkmanager.enable = lib.mkForce false;
    nftables.enable = true;
  };
  proxmoxLXC.manageHostName = true;
  systemd.network.wait-online.enable = false;
  users.users.root.initialPassword = "nixos";
}
