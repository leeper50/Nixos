{ disko, lib, ... }:
let
  rootDir = ../../..;
in
{
  imports =
    map (p: rootDir + p) [
      /home/profiles/cli_nixos.nix
      /nixos
      /nixos/configs/mounts.nix
      /nixos/configs/local_networking.nix
      /nixos/services/avahi.nix
      /nixos/services/docker.nix
      /nixos/services/power.nix
      /restic
    ]
    ++ [ disko.nixosModules.disko ];
  local = {
    docker.komodo.enable = true;
    mounts = {
      docker = true;
      media = true;
    };
    restic.backups.stacks = {
      exclude = [
        "cache"
        "model-cache"
      ];
      paths = [
        "/etc/komodo/stacks"
      ];
      user = "root";
    };
  };
  networking = {
    defaultGateway6.interface = lib.mkForce "ens18";
    hostName = "komodo";
    interfaces.ens18 = {
      ipv4.addresses = [
        {
          address = "10.0.0.60";
          prefixLength = 8;
        }
      ];
      ipv6.addresses = [
        {
          address = "2600:1702:58c1:9acf::60";
          prefixLength = 64;
        }
      ];
    };
  };
  system.stateVersion = "25.11";
}
