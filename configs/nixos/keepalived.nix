{
  config,
  globals,
  lib,
  localLib,
  pkgs,
  ...
}:
let
  checkDns = pkgs.writeShellScript "check-dns" ''
    answer=$(${pkgs.dnsutils}/bin/dig +short +time=1 +tries=1 @127.0.0.1 dnstest.dellhplaptop.xyz A) || exit 1
    [ -n "$answer" ]
  '';
  nodes =
    lib.mapAttrs
      (
        name: node:
        node
        // {
          ipv4Addr = globals.networking.hosts.${name}.ipv4;
          ipv6Addr = globals.networking.hosts.${name}.ipv6;
        }
      )
      {
        "nas" = {
          priority = 70;
          state = "BACKUP";
        };
        "node-1" = {
          priority = 100;
          state = "MASTER";
        };
        "node-2" = {
          priority = 90;
          state = "BACKUP";
        };
        "node-3" = {
          priority = 80;
          state = "BACKUP";
        };
      };
  thisNode = nodes.${config.networking.hostName};
  peers = lib.filterAttrs (name: _: name != config.networking.hostName) nodes;
  peeripv4Addrs = lib.filter (a: a != null) (lib.mapAttrsToList (_: node: node.ipv4Addr) peers);
  peeripv6Addrs = lib.filter (a: a != null) (lib.mapAttrsToList (_: node: node.ipv6Addr) peers);
in
{
  config = lib.mkMerge [
    {
      services.keepalived = {
        enable = true;
        enableScriptSecurity = true;
        extraConfig = lib.mkIf (thisNode.ipv4Addr != null && thisNode.ipv6Addr != null) ''
          vrrp_sync_group dns {
            group {
              dnsIPv4
              dnsIPv6
            }
          }
        '';
        vrrpInstances.dnsIPv4 = lib.mkIf (thisNode.ipv4Addr != null) {
          interface = "ens18";
          priority = thisNode.priority;
          state = thisNode.state;
          trackScripts = [ "checkDns" ];
          unicastPeers = peeripv4Addrs;
          unicastSrcIp = thisNode.ipv4Addr;
          virtualIps = [
            { addr = "10.0.1.1/8"; }
          ];
          virtualRouterId = 51;
        };
        vrrpInstances.dnsIPv6 = lib.mkIf (thisNode.ipv6Addr != null) {
          interface = "ens18";
          priority = thisNode.priority;
          state = thisNode.state;
          trackScripts = [ "checkDns" ];
          unicastSrcIp = thisNode.ipv6Addr;
          unicastPeers = peeripv6Addrs;
          virtualIps = [
            { addr = "${globals.networking.ipv6.prefix}::1:1/${globals.networking.ipv6.subnetMask}"; }
          ];
          virtualRouterId = 52;
        };
        vrrpScripts.checkDns = {
          fall = 2;
          interval = 2;
          rise = 2;
          script = "${checkDns}";
          timeout = 2;
        };
      };
      users = {
        groups.keepalived_script = { };
        users.keepalived_script = {
          group = "keepalived_script";
          isSystemUser = true;
        };
      };
    }
    {
      networking.firewall = localLib.mkFirewallRules {
        service = "keepalived";
        sources = lib.filter (a: a != null) (
          lib.concatMap (n: [
            n.ipv4Addr
            n.ipv6Addr
          ]) (lib.attrValues nodes)
        );
        protocols = [ "VRRP" ];
      };
    }
  ];
}
