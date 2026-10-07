{
  config,
  globals,
  localLib,
  ...
}:
let
  ports.webui = 9090;
in
{
  networking.firewall = localLib.mkFirewallRules {
    service = "cockpit";
    sources = globals.networking.lan;
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
