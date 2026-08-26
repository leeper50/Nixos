{ config, lib, ... }:
let
  cfg = config.local.beszel;
  ports.agent = 8090;
in
{
  options.local.beszel = {
    hub.enable = lib.mkEnableOption "host";
    agent.hubHost = lib.mkOption {
      default = "node-1.local";
      type = lib.types.str;
    };
  };
  config = lib.mkMerge [
    {
      services.beszel.agent = {
        enable = true;
        environment = {
          "HUB_URL" = "http://${cfg.agent.hubHost}:${toString ports.agent}";
          "KEY" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICNcggS7ZMLtGUfM0HTrqfj9jK6ezXoSj1MzDJOv6cOs";
          "TOKEN_FILE" = config.age.secrets."beszel_token.age".path;
        };
        openFirewall = true;
      };
      users.groups.beszel-agent.gid = 992;
    }
    (lib.mkIf cfg.hub.enable {
      networking.firewall.allowedTCPPorts = [
        ports.agent
      ];
      services.beszel.hub = {
        enable = true;
        host = "0.0.0.0";
        port = ports.agent;
      };
    })
  ];
}
