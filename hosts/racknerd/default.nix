{ globals, pkgs, ... }:
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
  services.microsocks = {
    enable = true;
    ip = globals.networking.tailnet.racknerd.ipv4;
  };
  system.stateVersion = "23.11";
  zramSwap.enable = false;
}
