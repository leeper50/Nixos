{ disko, ... }:
let
  rootDir = ../..;
  homelab = rootDir + /configs/nixos/homelab;
in
{
  imports =
    map (p: homelab + p) [
      /adguardhome.nix
      /docker.nix
      /keepalived.nix
    ]
    ++ [
      disko.nixosModules.disko
      (import ./vm-disk-config.nix {
        dataMountpoint = "/var/lib/docker";
        dataFormat = "xfs";
      })
    ];
  local = {
    adguardhome.enable = true;
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
  systemd.services.docker = {
    after = [ "mnt-media.mount" ];
    requires = [ "mnt-media.mount" ];
    unitConfig.RequiresMountsFor = [
      "/mnt/media"
      "/var/lib/docker"
    ];
  };
}
