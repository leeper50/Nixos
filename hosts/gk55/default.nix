{ ... }:
let
  rootDir = ../..;
in
{
  imports =
    map (p: rootDir + p) [
      /configs/nixos
      /configs/nixos/avahi.nix
      /configs/nixos/networking.nix
      /configs/nixos/profiles/cli.nix
    ]
    ++ [
      ./hardware-configuration.nix
    ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  local.networking.local = true;
  networking = {
    hostName = "gk55";
    interfaces.enp1s0 = {
      ipv4.addresses = [
        {
          address = "10.0.0.20";
          prefixLength = 8;
        }
      ];
    };
  };

  system.stateVersion = "25.11";
}
