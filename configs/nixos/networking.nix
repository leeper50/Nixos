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
        defaultGateway.address = globals.networking.gatewayV4;
        defaultGateway6.address = globals.networking.gatewayV6;
        hosts = ipToDomains;
        nameservers = globals.networking.nameservers.local ++ globals.networking.nameservers.public;
      };
    })
  ];
}
