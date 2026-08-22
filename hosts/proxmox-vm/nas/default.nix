{
  disko,
  globals,
  lib,
  ...
}:
let
  backupKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMOWw3itt6X+guXpUY1m5M2inL0Zs+Fs0nTrUOqDwZ/c root@node-1"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF99jYxJYq1frbpyemmxb7+G4+N0Q0XF77sNDiQcphc4 root@node-2"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMqG4JLWJ+lFKdOqTnY/gNHMoYLx82NjaTmwE7Lo1tJG root@node-3"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPieb/L9L+lfCvkA2nXaRZmvwbByskxXPLMV8PI4hmxG root@komodo"
  ];
  rootDir = ../../..;
in
{
  imports =
    map (p: rootDir + p) [
      /home/profiles/cli_nixos.nix
      /nixos
      /nixos/services/avahi.nix
      /nixos/services/beszel.nix
      /nixos/services/nfs.nix
      /nixos/services/postgresql.nix
      /nixos/services/rustfs.nix
      /nixos/services/samba.nix
      /restic
      /syncthing/nixos.nix
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
    defaultGateway6.interface = lib.mkForce "ens18";
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
    root = {
      openssh.authorizedKeys.keys = backupKeys;
    };
    ${globals.username} = {
      openssh.authorizedKeys.keys = backupKeys;
    };
  };
}
