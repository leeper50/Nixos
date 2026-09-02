{
  config,
  globals,
  lib,
  ...
}:
let
  cfg = config.local.beszel;
  ports.hub = 8090;
in
{
  options.local.beszel = {
    hub.enable = lib.mkEnableOption "host";
    agent.hubHost = lib.mkOption {
      default = "node-1.ts.${globals.domain}";
      type = lib.types.str;
    };
  };
  config = lib.mkMerge [
    {
      services.beszel.agent = {
        enable = true;
        environment = {
          "HUB_URL" = "http://${cfg.agent.hubHost}:${toString ports.hub}";
          "KEY" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICNcggS7ZMLtGUfM0HTrqfj9jK6ezXoSj1MzDJOv6cOs";
          "TOKEN_FILE" = config.age.secrets."beszel_token.age".path;
        };
      };
      users.groups.beszel-agent.gid = 992;
    }
    (lib.mkIf cfg.hub.enable {
      networking.firewall = globals.mkFirewallRules {
        service = "beszel";
        sources = [
          globals.networking.ipv4.lanSubnet
          globals.networking.ipv6.lanSubnet
        ];
        tcpPorts = [ ports.hub ];
      };
      services.beszel.hub = {
        enable = true;
        host = "0.0.0.0";
        port = ports.hub;
      };
    })
  ];
}
