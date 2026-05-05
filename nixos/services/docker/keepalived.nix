{
  config,
  lib,
  ...
}:
let
  nodes = {
    "node-1" = {
      addr = "10.0.0.21";
      priority = 100;
    };
    "node-2" = {
      addr = "10.0.0.22";
      priority = 90;
    };
    "node-3" = {
      addr = "10.0.0.23";
      priority = 80;
    };
  };
  thisNode = nodes.${config.networking.hostName};
  peerAddrs = lib.mapAttrsToList (_: v: v.addr) (
    lib.filterAttrs (name: _: name != config.networking.hostName) nodes
  );
in
{
  services.keepalived = {
    enable = true;
    vrrpInstances.swarm = {
      interface = "eth0";
      state = if config.networking.hostName == "node-1" then "MASTER" else "BACKUP";
      virtualRouterId = 51;
      priority = thisNode.priority;
      virtualIps = [
        { addr = "10.0.1.1/8"; }
      ];
      unicastSrcIp = thisNode.addr;
      unicastPeers = peerAddrs;
    };
  };
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p 112 -j nixos-fw-accept
  '';
}
