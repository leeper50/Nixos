{
  config,
  lib,
  ...
}:
let
  nodes = {
    "node-1" = {
      ipv4Addr = "10.0.0.21";
      ipv6Addr = "2600:1702:58c1:9acf::21";
      priority = 100;
    };
    "node-2" = {
      ipv4Addr = "10.0.0.22";
      ipv6Addr = "2600:1702:58c1:9acf::22";
      priority = 90;
    };
    "node-3" = {
      ipv4Addr = "10.0.0.23";
      ipv6Addr = "2600:1702:58c1:9acf::23";
      priority = 80;
    };
  };
  thisNode = nodes.${config.networking.hostName};
  peeripv4Addrs = lib.mapAttrsToList (_: v: v.ipv4Addr) (
    lib.filterAttrs (name: _: name != config.networking.hostName) nodes
  );
  peeripv6Addrs = lib.mapAttrsToList (_: v: v.ipv6Addr) (
    lib.filterAttrs (name: _: name != config.networking.hostName) nodes
  );
in
{
  config = lib.mkMerge [
    {
      services.keepalived = {
        enable = true;
        vrrpInstances.dnsIPv4 = {
          interface = "eth0";
          priority = thisNode.priority;
          state = if config.networking.hostName == "node-1" then "MASTER" else "BACKUP";
          unicastPeers = peeripv4Addrs;
          unicastSrcIp = thisNode.ipv4Addr;
          virtualIps = [
            { addr = "10.0.1.1/8"; }
          ];
          virtualRouterId = 51;
        };
        vrrpInstances.dnsIPv6 = {
          interface = "eth0";
          priority = thisNode.priority;
          state = if config.networking.hostName == "node-1" then "MASTER" else "BACKUP";
          unicastSrcIp = thisNode.ipv6Addr;
          unicastPeers = peeripv6Addrs;
          virtualIps = [
            { addr = "2600:1702:58c1:9acf::1:1/64"; }
          ];
          virtualRouterId = 52;
        };
      };
    }
    (lib.mkIf config.networking.nftables.enable {
      networking.firewall.extraInputRules = ''
        meta l4proto 112 accept
      '';
    })
    (lib.mkIf (!config.networking.nftables.enable) {
      networking.firewall.extraCommands = ''
        iptables -A nixos-fw -p 112 -j nixos-fw-accept
        ip6tables -A nixos-fw -p 112 -j nixos-fw-accept
      '';
    })
  ];
}
