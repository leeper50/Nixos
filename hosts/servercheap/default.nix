{ config, pkgs, ... }:
let
  rootDir = ../..;
in
{
  imports =
    map (p: rootDir + p) [
      /home/profiles/cli_nixos.nix
      /nixos
      /nixos/services/docker.nix
      /nixos/services/i2pd.nix
    ]
    ++ [
      ./hardware-configuration.nix
    ];
  local.i2pd = {
    bandwidth = 62500;
    enableIPv6 = true;
    port = 51175;
    privateAddress = "100.121.87.44";
    publicAddress = "65.75.202.6";
  };
  networking = {
    defaultGateway = {
      address = "65.75.202.1";
      interface = "ens3";
    };
    defaultGateway6 = {
      address = "2606:cc0:11:2300::1";
      interface = "ens3";
    };
    hostName = "servercheap";
    nameservers = [
      "9.9.9.9"
      "149.112.112.112"
      "2620:fe::9"
      "2620:fe::fe"
    ];
    interfaces.ens3 = {
      ipv4.addresses = [
        {
          address = "65.75.202.6";
          prefixLength = 25;
        }
      ];
      ipv6.addresses = [
        {
          address = "2606:cc0:11:2351::1";
          prefixLength = 64;
        }
      ];
    };
  };
  system.stateVersion = "25.11";
}
