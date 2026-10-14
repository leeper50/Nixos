{ pkgs, ... }:
let
  rootDir = ../..;
  homelab = rootDir + /configs/nixos/homelab;
in
{
  imports =
    map (p: homelab + p) [
      /murmur.nix
      /proxies.nix
    ]
    ++ [
      (rootDir + /configs/nixos)
      ./hardware-configuration.nix
    ];
  boot.tmp.cleanOnBoot = true;
  environment.systemPackages = with pkgs; [
    openssl
  ];
  local = {
    proxies.microsocks.enable = true;
    beszel.agent.enable = true;
    caddy = {
      domain = "19280085.xyz";
      enable = true;
      provider = "porkbun";
    };
    murmur = {
      enable = true;
      name = "Da Bad One";
      tls = {
        domain = "vc.19280085.xyz";
        enable = true;
        provider = "porkbun";
      };
    };
  };
  system.stateVersion = "23.11";
  zramSwap.enable = false;
}
