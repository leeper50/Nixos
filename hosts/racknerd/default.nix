{ pkgs, ... }:
let
  rootDir = ../..;
in
{
  imports =
    map (p: rootDir + p) [
      /configs/nixos
      /configs/nixos/murmur.nix
    ]
    ++ [
      ./hardware-configuration.nix
    ];
  boot.tmp.cleanOnBoot = true;
  environment.systemPackages = with pkgs; [
    openssl
  ];
  local = {
    beszel.agent.enable = true;
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
