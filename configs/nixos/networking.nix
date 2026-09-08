{
  config,
  globals,
  lib,
  ...
}:
let
  domainPairs = lib.flatten (
    lib.mapAttrsToList (domain: ips: map (ip: { inherit domain ip; }) ips) globals.networking.hosts
  );
  ipToDomains = lib.mapAttrs (ip: pairs: map (p: p.domain) pairs) (lib.groupBy (p: p.ip) domainPairs);
in
{
  config = lib.mkMerge [
    {
      networking = {
        firewall = {
          allowPing = true;
          enable = true;
          trustedInterfaces = [ "tailscale0" ];
        };
        nameservers = globals.networking.nameservers.public;
        networkmanager.enable = true;
        nftables.enable = true;
      };
      services.tailscale = {
        authKeyFile = config.age.secrets."headscale_preauth_key.age".path;
        enable = true;
        extraUpFlags = [
          "--login-server=https://hd.${globals.domain}"
        ];
      };
    }
    (lib.mkIf (config.local.local) {
      networking = {
        defaultGateway.address = globals.networking.ipv4.gateway;
        defaultGateway6.address = globals.networking.ipv6.gateway;
        hosts = ipToDomains;
        nameservers = globals.networking.nameservers.local ++ globals.networking.nameservers.public;
      };
    })
  ];
}
