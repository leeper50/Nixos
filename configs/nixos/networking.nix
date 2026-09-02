{
  config,
  globals,
  lib,
  ...
}:
let
  cfg = config.local.networking;
  domainPairs = lib.flatten (
    lib.mapAttrsToList (domain: ips: map (ip: { inherit domain ip; }) ips) globals.networking.hosts
  );
  ipToDomains = lib.mapAttrs (ip: pairs: map (p: p.domain) pairs) (lib.groupBy (p: p.ip) domainPairs);
in
{
  options.local.networking = {
    local = lib.mkEnableOption "local";
  };
  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = config.networking.nftables.enable;
          message = "globals.mkFirewallRules emits nftables rules only; the iptables backend ignores extraInputRules, so every generated rule would be silently dropped.";
        }
      ];
      networking = {
        firewall = {
          allowPing = true;
          enable = true;
        };
        nameservers = globals.networking.nameservers.public;
        networkmanager.enable = true;
        nftables.enable = true;
      };
    }
    (lib.mkIf (cfg.local) {
      networking = {
        defaultGateway.address = globals.networking.ipv4.gateway;
        defaultGateway6.address = globals.networking.ipv6.gateway;
        hosts = ipToDomains;
        nameservers = globals.networking.nameservers.local ++ globals.networking.nameservers.public;
      };
    })
  ];
}
