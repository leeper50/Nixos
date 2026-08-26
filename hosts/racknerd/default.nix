{ pkgs, ... }:
let
  rootDir = ../..;
in
{
  imports =
    map (p: rootDir + p) [
      /configs/home/profiles/cli_nixos.nix
      /configs/nixos
      /configs/nixos/beszel.nix
      /configs/nixos/murmur.nix
      /configs/nixos/networking.nix
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
    beszel.agent.hubHost = "100.68.73.88";
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
  networking = {
    firewall.trustedInterfaces = [ "tailscale0" ];
    hostName = "racknerd";
  };
  services = {
    microsocks = {
      enable = true;
      ip = "100.92.216.84";
    };
  };
  system.stateVersion = "23.11";
  zramSwap.enable = false;
}
