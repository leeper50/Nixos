{ globals, ... }:
let
  rootDir = ../..;
in
{
  imports =
    map (p: rootDir + p) [
      /configs/nixos
      /configs/nixos/authelia.nix
      /configs/nixos/headscale.nix
      /configs/nixos/murmur.nix
      /configs/nixos/proxies.nix
    ]
    ++ [
      ./hardware-configuration.nix
    ];
  local = {
    authelia.enable = true;
    beszel.agent.enable = true;
    comin.enable = true;
    caddy = {
      domain = globals.domains.primary;
      enable = true;
    };
    headscale.enable = true;
    murmur = {
      enable = true;
      name = "Freedom General";
      tls.enable = true;
    };
    proxies.i2p = {
      enable = true;
      enableIPv6 = true;
      port = 59230;
    };
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

  services.microsocks = {
    enable = true;
    ip = globals.networking.tailnet.servercheap.ipv4;
  };
  system.stateVersion = "25.11";
}
