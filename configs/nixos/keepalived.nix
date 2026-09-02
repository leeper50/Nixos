{
  config,
  globals,
  lib,
  pkgs,
  ...
}:
let
  checkAdguard = pkgs.writeShellScript "check-adguard" ''
    answer=$(${pkgs.dnsutils}/bin/dig +short +time=1 +tries=1 @127.0.0.1 dnstest.dellhplaptop.xyz A) || exit 1
    [ -n "$answer" ]
  '';
  nodes = {
    "node-1" = {
      ipv4Addr = "10.0.0.21";
      ipv6Addr = "2600:1702:58c1:9acf::21";
      priority = 100;
      state = "MASTER";
    };
    "node-2" = {
      ipv4Addr = "10.0.0.22";
      ipv6Addr = "2600:1702:58c1:9acf::22";
      priority = 90;
      state = "BACKUP";
    };
    "node-3" = {
      ipv4Addr = "10.0.0.23";
      ipv6Addr = "2600:1702:58c1:9acf::23";
      priority = 80;
      state = "BACKUP";
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
        enableScriptSecurity = true;
        extraConfig = ''
          vrrp_sync_group dns {
            group {
              dnsIPv4
              dnsIPv6
            }
          }
        '';
        vrrpInstances.dnsIPv4 = {
          interface = "eth0";
          priority = thisNode.priority;
          state = thisNode.state;
          trackScripts = [ "chkAdguard" ];
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
          state = thisNode.state;
          trackScripts = [ "chkAdguard" ];
          unicastSrcIp = thisNode.ipv6Addr;
          unicastPeers = peeripv6Addrs;
          virtualIps = [
            { addr = "2600:1702:58c1:9acf::1:1/64"; }
          ];
          virtualRouterId = 52;
        };
        vrrpScripts.chkAdguard = {
          fall = 2;
          interval = 2;
          rise = 2;
          script = "${checkAdguard}";
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
      networking.firewall = globals.mkFirewallRules {
        service = "keepalived";
        sources = globals.networking.swarmAddresses;
        protocols = [ 112 ]; # VRRP
      };
    }
  ];
}
