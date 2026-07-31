{ config, lib, ... }:
let
  cfg = config.local.beszel;
in
{
  options.local.beszel = {
    hub.enable = lib.mkEnableOption "host";
    agent.hubHost = lib.mkOption {
      default = "komodo.local";
      type = lib.types.str;
    };
  };
  config = lib.mkMerge [
    {
      services.beszel.agent = {
        enable = true;
        environment = {
          "HUB_URL" = "http://${cfg.agent.hubHost}:8090";
          "KEY" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPrPvS3EnwuIsWXEnSejGIN75hP+Tdbi6TLoKv5l/fqs";
          "TOKEN_FILE" = config.age.secrets."beszel_token.age".path;
        };
        openFirewall = true;
      };
      users.groups.beszel-agent.gid = 992;
    }
    (lib.mkIf cfg.hub.enable {
      networking.firewall.allowedTCPPorts = [
        8090
      ];
      services.beszel.hub = {
        enable = true;
        host = "0.0.0.0";
        port = 8090;
      };
    })
  ];
}
