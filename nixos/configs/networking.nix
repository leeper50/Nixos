{
  config,
  globals,
  lib,
  ...
}:
let
  cfg = config.local.networking;
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
        nameservers = globals.nameservers.public;
        networkmanager.enable = true;
        nftables.enable = true;
      };
    }
    (lib.mkIf (cfg.local) {
      networking = {
        defaultGateway.address = "10.0.0.1";
        defaultGateway6.address = "2600:1702:58c1:9acf:f2a7:31ff:fe94:abac";
        hosts = {
          "10.0.0.21" = [ "node-1.local" ];
          "10.0.0.22" = [ "node-2.local" ];
          "10.0.0.23" = [ "node-3.local" ];
          "10.0.0.52" = [ "nas.local" ];
          "10.0.0.60" = [
            "komodo.local"
          ];
          "10.0.1.1" = [
            "buncha.men"
            "dellhplaptop.xyz"
          ];
          "2600:1702:58c1:9acf::21" = [ "node-1.local" ];
          "2600:1702:58c1:9acf::22" = [ "node-2.local" ];
          "2600:1702:58c1:9acf::23" = [ "node-3.local" ];
          "2600:1702:58c1:9acf::52" = [ "nas.local" ];
          "2600:1702:58c1:9acf::60" = [
            "komodo.local"
          ];
          "2600:1702:58c1:9acf::1:1" = [
            "buncha.men"
            "dellhplaptop.xyz"
          ];
        };
        nameservers = globals.nameservers.local ++ globals.nameservers.public;
      };
    })
  ];
}
