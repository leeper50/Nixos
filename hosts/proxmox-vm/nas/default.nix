{ disko, globals, ... }:
let
  rootDir = ../../..;
  keys = import (rootDir + /secrets/keys.nix);
  backupKeys = [
    keys.node-1
    keys.node-2
    keys.node-3
    keys.komodo
  ];
in
{
  imports =
    map (p: rootDir + p) [
      /configs/nixos/nfs.nix
      /configs/nixos/postgresql.nix
      /configs/nixos/rustfs.nix
      /configs/nixos/samba.nix
      /configs/nixos/syncthing.nix
    ]
    ++ [ disko.nixosModules.disko ];
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
    networking.local = true;
    postgresql = {
      databases = [
        "forgejo"
        "freshrss"
        "rxresume"
      ];
      enable = true;
    };
      ];
      enable = true;
    };
    restic.backups.postgresql = {
      paths = [ "/mnt/data/postgresql-backups" ];
      user = "root";
    };
    syncthing = {
      folders = {
        "FreeTube" = {
          enable = true;
          type = "receiveonly";
        };
        "GlobalShare" = {
          enable = true;
          type = "receiveonly";
        };
        "Notes" = {
          enable = true;
          type = "receiveonly";
        };
      };
      home = "/mnt/data/home/${globals.username}";
    };
  };
  networking = {
    hostName = "nas";
    interfaces.ens18 = {
      ipv4.addresses = [
        {
          address = "10.0.0.52";
          prefixLength = 8;
        }
      ];
      ipv6.addresses = [
        {
          address = "2600:1702:58c1:9acf::52";
          prefixLength = 64;
        }
      ];
    };
  };
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/mnt/data" ];
  };
  system.stateVersion = "25.11";
  users.users = {
    ${globals.username}.openssh.authorizedKeys.keys = backupKeys;
    root.openssh.authorizedKeys.keys = backupKeys;
  };
}
