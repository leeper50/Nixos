{ pkgs, ... }:
let
  rootDir = ../..;
in
{
  imports =
    map (p: rootDir + p) [
      /home/profiles/cli_nixos.nix
      /nixos
      /nixos/services/docker.nix
      /nixos/services/i2pd.nix
      /nixos/services/murmur.nix
    ]
    ++ [
      ./hardware-configuration.nix
    ];
  boot.tmp.cleanOnBoot = true;
  environment.systemPackages = with pkgs; [
    openssl
  ];
  local.docker.remote = true;
  local.i2pd = {
    bandwidth = 62500;
    enableIPv6 = false;
    port = 62271;
    privateAddress = "100.92.216.84";
    publicAddress = "107.174.237.4";
  };
  networking = {
    firewall = {
      enable = true;
      trustedInterfaces = [ "tailscale0" ];
      extraCommands = ''
        iptables -A DOCKER-USER ! -i tailscale0 -p tcp --dport 8120 -j DROP
      '';
    };
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
