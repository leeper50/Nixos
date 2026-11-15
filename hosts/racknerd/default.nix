{ pkgs, ... }:
{
  imports = [
    ../../configs/nixos
    ../../configs/nixos/homelab/murmur.nix
    ../../configs/nixos/homelab/proxies.nix
    ./hardware-configuration.nix
  ];
  boot.tmp.cleanOnBoot = true;
  environment.systemPackages = with pkgs; [
    openssl
  ];
  local = {
    proxies.microsocks.enable = true;
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
