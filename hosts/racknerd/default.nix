{ pkgs, ... }:
let
  rootDir = ../..;
in
{
  imports =
    map (p: rootDir + p) [
      /configs/nixos
      /configs/nixos/beszel.nix
      /configs/nixos/murmur.nix
      /configs/nixos/networking.nix
      /configs/nixos/profiles/cli.nix
      /configs/nixos/proxies.nix
    ]
    ++ [
      ./hardware-configuration.nix
    ];
  boot.tmp.cleanOnBoot = true;
  environment.systemPackages = with pkgs; [
    openssl
  ];
  local = {
    beszel.agent.hubHost = "100.64.0.5";
    murmur = {
      enable = true;
      name = "Da Bad One";
      tls = {
        domain = "vc.19280085.xyz";
        enable = true;
        provider = "porkbun";
      };
    };
    proxies = {
      i2p = {
        enable = true;
        enableIPv6 = false;
        port = 62271;
      };
      tor = {
        enable = false;
        name = "engagingaugmented";
        port = 36411;
      };
    };
  };
  networking.hostName = "racknerd";
  services = {
    microsocks = {
      enable = true;
      ip = "100.64.0.3";
    };
  };
  system.stateVersion = "23.11";
  zramSwap.enable = false;
}
