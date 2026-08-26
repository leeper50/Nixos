{ ... }:
let
  rootDir = ../..;
in
{
  imports =
    map (p: rootDir + p) [
      /configs/home/profiles/cli_nixos.nix
      /configs/nixos
      /configs/nixos/beszel.nix
      /configs/nixos/networking.nix
      /configs/nixos/proxies.nix
    ]
    ++ [
      ./hardware-configuration.nix
    ];
  local = {
    beszel.agent.hubHost = "100.68.73.88";
    proxies = {
      i2p = {
        enable = true;
        enableIPv6 = true;
        port = 51175;
      };
      tor = {
        enable = false;
        name = "landeddemeanor";
        port = 47442;
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
    firewall.trustedInterfaces = [ "tailscale0" ];
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
