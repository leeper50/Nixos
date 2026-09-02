{ config, globals, ... }:
let
  ports.webui = 9090;
in
{
  networking.firewall = globals.mkFirewallRules {
    service = "cockpit";
    sources = [
      globals.networking.ipv4.lanSubnet
      globals.networking.ipv6.lanSubnet
    ];
    tcpPorts = [ ports.webui ];
  };
  services.cockpit = {
    allowed-origins = [
      "https://${config.networking.hostName}.local:${toString ports.webui}"
    ];
    enable = true;
    port = ports.webui;
    settings.WebService.AllowUnencrypted = true;
  };
}
