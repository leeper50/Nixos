{ lib, modulesPath, ... }:
let
  rootDir = ../..;
in
{
  imports =
    map (p: rootDir + p) [
      /configs/home/restic.nix
      /configs/nixos
      /configs/nixos/adguardhome.nix
      /configs/nixos/avahi.nix
      /configs/nixos/beszel.nix
      /configs/nixos/docker.nix
      /configs/nixos/keepalived.nix
      /configs/nixos/mounts.nix
      /configs/nixos/networking.nix
      /configs/nixos/power.nix
      /configs/nixos/profiles/cli.nix
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
  };
  proxmoxLXC.manageHostName = true;
  systemd.network.wait-online.enable = false;
}
