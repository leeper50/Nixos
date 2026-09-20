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
      /configs/nixos/nginx.nix
      /configs/nixos/murmur.nix
    ]
    ++ [
      ./hardware-configuration.nix
    ];
  local = {
    authelia.enable = true;
    beszel.agent.enable = true;
    comin.enable = true;
    headscale.enable = true;
    nginx = {
      domain = globals.domain;
      enable = true;
      tls.provider = "cloudflare";
    };
    murmur = {
      enable = true;
      name = "Freedom General";
      tls = {
        domain = "vc.${globals.domain}";
        enable = true;
        provider = "cloudflare";
      };
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
    hostName = "servercheap";
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
