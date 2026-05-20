{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

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
      "2620:fe::fe"
      "2620:fe::9"
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
  services.tailscale.enable = true;

  system.stateVersion = "25.11";

  virtualisation.docker = {
    enable = true;
    liveRestore = false;
  };
  virtualisation.oci-containers.backend = "docker";
}
