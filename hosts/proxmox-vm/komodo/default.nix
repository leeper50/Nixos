{ disko, ... }:
let
  rootDir = ../../..;
in
{
  imports =
    map (p: rootDir + p) [
      /configs/nixos/blocky.nix
      /configs/nixos/docker.nix
      /configs/nixos/keepalived.nix
    ]
    ++ [
      disko.nixosModules.disko
      ../disk-config.nix
    ];
  boot.kernelModules = [
    "nft_masq"
    "wireguard"
  ];
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
  local = {
    beszel.agent.enable = true;
    comin.enable = true;
    docker.komodo = {
      coreIP = "100.64.0.5";
      periphery.enable = true;
    };
    local = true;
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
