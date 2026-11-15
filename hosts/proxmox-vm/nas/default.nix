{ disko, ... }:
{
  imports = [
    ../../../configs/nixos/homelab/attic.nix
    ../../../configs/nixos/homelab/blocky.nix
    ../../../configs/nixos/homelab/keepalived.nix
    ../../../configs/nixos/homelab/media-watch.nix
    ../../../configs/nixos/homelab/nfs.nix
    ../../../configs/nixos/homelab/postgresql.nix
    ../../../configs/nixos/homelab/redis.nix
    ../../../configs/nixos/homelab/rustfs.nix
    ../../../configs/nixos/homelab/samba.nix
    ../../../configs/nixos/syncthing.nix
    disko.nixosModules.disko
    (import ../vm-disk-config.nix {
      dataMountpoint = "/mnt/attic";
      dataFormat = "xfs";
    })
  ];
  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/f7f51e6b-f23b-4aee-9498-6430dff7401e";
    fsType = "btrfs";
    options = [
      "degraded"
      "nofail"
      "noatime"
      "space_cache=v2"
    ];
  };
  local = {
    attic.enable = true;
    caddy.enable = true;
    media-watch.enable = true;
    local = true;
    postgresql = {
      databases = [
        "forgejo"
        "freshrss"
        "mealie"
        "miniflux"
        "rxresume"
        "vaultwarden"
      ];
      enable = true;
    };
    redis = {
      databases = [
        "rxresume"
      ];
      enable = true;
    };
    restic.backups.postgresql = {
      paths = [ "/mnt/data/postgresql-backups" ];
      user = "root";
    };
    rustfs.enable = true;
    syncthing = {
      folder_type = "receiveonly";
      home = "/mnt/data/home/walter";
    };
  };
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/mnt/data" ];
  };
  system.stateVersion = "25.11";
}
