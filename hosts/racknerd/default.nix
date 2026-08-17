{ pkgs, ... }:
let
  rootDir = ../..;
in
{
  imports =
    map (p: rootDir + p) [
      /home/profiles/cli_nixos.nix
      /nixos
      /nixos/configs/networking.nix
      /nixos/services/beszel.nix
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
  local = {
    beszel.agent.hubHost = "100.126.187.39";
    docker = {
      komodo = {
        coreIP = "100.126.187.39";
        enable = true;
      };
      remote = true;
    };
    i2pd = {
      bandwidth = 62500;
      enable = true;
      enableIPv6 = false;
      port = 62271;
    };
  };
  networking = {
    firewall = {
      extraCommands = ''
        iptables -A DOCKER-USER ! -i tailscale0 -p tcp --dport 8120 -j DROP
      '';
      trustedInterfaces = [ "tailscale0" ];
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
