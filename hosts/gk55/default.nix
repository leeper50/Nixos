{ ... }:
let
  rootDir = ../..;
in
{
  imports =
    map (p: rootDir + p) [
      /home/profiles/cli_nixos.nix
      /nixos
      /nixos/configs/local_networking.nix
      /nixos/services/avahi.nix
    ]
    ++ [
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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
