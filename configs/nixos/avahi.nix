{
  config,
  globals,
  lib,
  localLib,
  ...
}:
{
  config = lib.mkMerge [
    (lib.mkIf config.local.local {
      networking.firewall = localLib.mkFirewallRules {
        service = "avahi";
        sources = globals.networking.lan.subnets ++ [
          globals.networking.lan.ipv6.linkLocalSubnet
        ];
        udpPorts = [ 5353 ];
      };
      services.avahi = {
        enable = true;
        nssmdns4 = true;
        nssmdns6 = true;
        openFirewall = false;
        settings.publish = {
          "disable-publishing" = false;
          publish-addresses = true;
          publish-domain = true;
          publish-workstation = true;
        };
      };
    })
  ];
}
