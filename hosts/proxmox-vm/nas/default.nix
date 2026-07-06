{ disko, lib, ... }:
let
  rootDir = ../../..;
in
{
  imports =
    map (p: rootDir + p) [
      /home/profiles/cli_nixos.nix
      /nixos
      /nixos/configs/local_networking.nix
      /nixos/services/avahi.nix
      /nixos/services/nfs.nix
      /nixos/services/samba.nix
      /syncthing/nas.nix
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
  networking = {
    defaultGateway6.interface = lib.mkForce "ens18";
    hostName = "nas";
    interfaces.ens18 = {
      ipv4.addresses = [
        {
          address = "10.0.0.33";
          prefixLength = 8;
        }
      ];
      ipv6.addresses = [
        {
          address = "2600:1702:58c1:9acf::33";
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
}
