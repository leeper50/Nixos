{
  config,
  globals,
  lib,
  localLib,
  ...
}:
let
  port = 8081;
  version = "sha-60c8fcd";
in
{
  options.local.redlib = {
    enable = lib.mkEnableOption "redlib";
  };
  config = lib.mkMerge [
    (lib.mkIf config.local.redlib.enable {
      virtualisation.oci-containers = {
        backend = "docker";
        containers.redlib = {
          image = "ghcr.io/nachtalb/redlib:${version}";
          environment = {
            ALL_PROXY = "socks5h://${globals.networking.lan.hosts.nas.ipv4}:1080";
            REDLIB_DEFAULT_LAYOUT = "compact";
            REDLIB_DEFAULT_SHOW_NSFW = "on";
            REDLIB_DEFAULT_SUBSCRIPTIONS = lib.concatStringsSep "+" [
              "baseball"
              "DataHoarder"
              "fountainpens"
              "homelab"
              "liberalgunowners"
              "NatureIsFuckingLit"
              "selfhosted"
              "unixporn"
            ];
            REDLIB_DEFAULT_THEME = "gruvboxdark";
            REDLIB_DEFAULT_USE_HLS = "on";
            REDLIB_DEFAULT_WIDE = "on";
            REDLIB_ROBOTS_DISABLE_INDEXING = "on";
            SFW_ONLY = "off";
          };
          ports = [ "127.0.0.1:${toString port}:8080" ];
        };
      };
    })
    (lib.mkIf (config.local.redlib.enable && config.services.caddy.enable) {
      services.caddy.virtualHosts = localLib.mkCaddyVirtualHosts {
        red = "reverse_proxy 127.0.0.1:${toString port}";
      };
    })
  ];
}
