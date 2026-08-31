{ ... }:
let
  rootDir = ../..;
in
{
  imports =
    map (p: rootDir + p) [
      /configs/nixos
      /configs/nixos/authelia.nix
      /configs/nixos/beszel.nix
      /configs/nixos/forgejo.nix
      /configs/nixos/freshrss.nix
      /configs/nixos/headscale.nix
      /configs/nixos/networking.nix
      /configs/nixos/nginx.nix
      /configs/nixos/profiles/cli.nix
      /configs/nixos/proxies.nix
    ]
    ++ [
      ./hardware-configuration.nix
    ];
  local = {
    authelia = {
      enable = true;
      headplaneOidcClientSecretHash = "$pbkdf2-sha512$310000$hPEHI5nF1jxjuq2hraFgsg$SAnFIc.C4YY0Nq3wUPgapva76X4j2J7bGlL4svCejLHEYRVyDh7u7KevS3yyH8e0fJszj5jAWOiJ/xaDC2sRTA";
      headscaleOidcClientSecretHash = "$pbkdf2-sha512$310000$bqQR9jguvCA3dHh8twp7Xg$BL/QJrhvx7KUX/tNeC.W4qY6vX88EtCL6DXts4kh3447MYvQz631iYQApPmsh3asn1/DM6ydKXZ9aUahkBhDrA";
    };
    beszel.agent.hubHost = "100.64.0.5";
    forgejo = {
      server.enable = true;
      runner.enable = true;
      runner.uuid = "8fc95947-6d0d-4138-9999-e5e4d17e392b";
    };
    headscale.enable = true;
    nginx.enable = true;
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
