{
  config,
  globals,
  lib,
  localLib,
  ...
}:
let
  cfg = config.local.redlib;
  port = 8080;
  version = "sha-7f192ae";
in
{
  options.local.redlib = {
    enable = lib.mkEnableOption "redlib";
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      virtualisation.oci-containers = {
        backend = "docker";
        containers.redlib = {
          image = "docker.io/luciferscircle/redlib:${version}";
          environment = {
            ALL_PROXY = "socks5h://${globals.networking.hosts.node-1.ipv4}:1080";
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
          };
          extraOptions = [ "--network=host" ];
        };
      };
    })
    (lib.mkIf (cfg.enable && config.services.caddy.enable) {
      services.caddy.virtualHosts = localLib.mkCaddyVirtualHosts {
        red = "reverse_proxy 127.0.0.1:${toString port}";
      };
    })
  ];
}
