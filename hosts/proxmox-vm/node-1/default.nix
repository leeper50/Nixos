{ globals, localLib, ... }:
let
  rootDir = ../../..;
  homelab = rootDir + /configs/nixos/homelab;
in
{
  imports = map (p: homelab + p) [
    /renovate.nix
    /vaultwarden.nix
  ];
  local = {
    beszel.hub.enable = true;
    docker = {
      komodo = {
        core.enable = true;
        coreIP = globals.networking.hosts.node-1.ipv4;
        periphery.enable = true;
      };
      swarm = {
        manager = true;
        managerIP = globals.networking.hosts.node-1.ipv4;
      };
    };
    fail2ban.jails.traefik.enable = true;
    renovate.enable = true;
    vaultwarden.enable = true;
  };
  networking.firewall = localLib.mkFirewallRules {
    service = "traefik";
    sources = [
      "0.0.0.0"
      "::0"
    ];
    tcpPorts = [
      80
      443
    ];
    udpPorts = [ 443 ];
  };
  system.stateVersion = "25.11";
}
