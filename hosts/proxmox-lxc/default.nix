{ lib, modulesPath, ... }:
let
  rootDir = ../..;
in
{
  imports =
    map (p: rootDir + p) [
      /configs/nixos
      /configs/nixos/adguardhome.nix
      /configs/nixos/docker.nix
      /configs/nixos/keepalived.nix
    ]
    ++ [
      (modulesPath + "/virtualisation/proxmox-lxc.nix")
    ];
  local = {
    beszel.agent.enable = true;
    docker.swarm.enable = true;
    local = true;
    mounts.media = true;
    restic.backups = {
      docker = {
        exclude = [
          "*cache*"
        ];
        paths = [
          "/etc/docker"
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
  systemd = {
    network.wait-online.enable = true;
    services.docker = {
      after = [ "mnt-media.mount" ];
      requires = [ "mnt-media.mount" ];
    };
  };
}
