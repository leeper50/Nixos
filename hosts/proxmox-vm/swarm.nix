{ disko, ... }:
let
  rootDir = ../..;
in
{
  imports =
    map (p: rootDir + p) [
      /configs/nixos/adguardhome.nix
      /configs/nixos/docker.nix
      /configs/nixos/keepalived.nix
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
  systemd.services.docker = {
    after = [ "mnt-media.mount" ];
    requires = [ "mnt-media.mount" ];
    unitConfig.RequiresMountsFor = [
      "/mnt/media"
      "/var/lib/docker"
    ];
  };
}
