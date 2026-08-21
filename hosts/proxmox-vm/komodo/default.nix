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
      /nixos/services/avahi.nix
      /nixos/services/beszel.nix
      /nixos/services/docker.nix
      /nixos/services/power.nix
      /restic
    ]
    ++ [ disko.nixosModules.disko ];
  boot.kernelModules = [
    "nft_masq"
    "wireguard"
  ];
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
  local = {
    docker.komodo = {
      coreIP = "10.0.0.21";
      enable = true;
    };
    networking.local = true;
    restic.backups.stacks = {
      exclude = [
        "*cache*"
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
  virtualisation.libvirtd.enable = true;
}
