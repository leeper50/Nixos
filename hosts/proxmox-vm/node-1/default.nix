{ globals, localLib, ... }:
let
  rootDir = ../../..;
  homelab = rootDir + /configs/nixos/homelab;
in
{
  imports = map (p: homelab + p) [
    /forgejo.nix
  ];
  local = {
    beszel.hub.enable = true;
    forgejo.runner = {
      enable = true;
      uuid = "ec3b754e-8dbb-4170-8e4c-7f88eca3e652";
    };
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
