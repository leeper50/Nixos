{ disko, secrets, ... }:
let
  rootDir = ../../..;
  homelab = rootDir + /configs/nixos/homelab;
  keys = import "${secrets}/keys.nix";
  backupKeys = [
    keys.node-1
    keys.node-2
    keys.node-3
  ];
in
{
  imports =
    map (p: homelab + p) [
      /attic.nix
      /blocky.nix
      /keepalived.nix
      /media-watch.nix
      /nfs.nix
      /postgresql.nix
      /redis.nix
      /rustfs.nix
      /samba.nix
    ]
    ++ [
      disko.nixosModules.disko
      (import ../vm-disk-config.nix {
        dataMountpoint = "/mnt/attic";
        dataFormat = "xfs";
      })
      (rootDir + /configs/nixos/syncthing.nix)
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
    beszel.agent.enable = true;
    caddy.enable = true;
    mediaWatch.enable = true;
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
  users.users = {
    walter.openssh.authorizedKeys.keys = backupKeys;
    root.openssh.authorizedKeys.keys = backupKeys;
  };
}
