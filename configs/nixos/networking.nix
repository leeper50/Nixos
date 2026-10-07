{
  config,
  globals,
  lib,
  ...
}:
let
  ipToDomains = lib.zipAttrs (
    lib.concatLists (
      lib.mapAttrsToList (
        domain:
        map (ip: {
          ${ip} = domain;
        })
      ) globals.networking.dns
    )
  );
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
          "--login-server=https://hd.${globals.domains.primary}"
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
