{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking = {
    nameservers = [ "9.9.9.9" ];
    hostName = "servercheap";
    defaultGateway = {
      address = "65.75.202.1";
      interface = "ens3";
    };
    interfaces.ens3 = {
      ipv4.addresses = [
        {
          address = "65.75.202.6";
          prefixLength = 25;
        }
      ];
    };
  };

  services.openssh.enable = true;
  system.stateVersion = "25.11";
}
