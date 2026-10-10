{ pkgs, ... }:
let
  rootDir = ../..;
in
{
  imports =
    map (p: rootDir + p) [
      /configs/nixos
      /configs/nixos/murmur.nix
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
    proxies.microsocks.enable = true;
    beszel.agent.enable = true;
    caddy = {
      domain = "19280085.xyz";
      enable = true;
      provider = "porkbun";
    };
    comin.enable = true;
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
