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
      /restic
    ]
    ++ [
      (modulesPath + "/virtualisation/proxmox-lxc.nix")
    ];
  local = {
    docker.swarm.enable = true;
    networking.local = true;
    mounts.media = true;
    restic.backups = {
      docker = {
        exclude = [
          "*cache*"
        ];
        paths = [
          "/etc/docker"
        ];
        user = "root";
      };
      volumes = {
        exclude = [
          "*cache*"
        ];
        paths = [
          "/var/lib/docker/volumes"
        ];
        user = "root";
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
}
