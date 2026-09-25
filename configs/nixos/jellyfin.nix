{
  config,
  globals,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.local.jellyfin;
  ports = {
    discovery = 7359;
    http = 8096;
  };
in
{
  options.local.jellyfin = {
    enable = lib.mkEnableOption "jellyfin";
    publishedServerUrl = lib.mkOption {
      default = "https://jf.dellhplaptop.xyz";
      type = lib.types.str;
    };
  };
  config = lib.mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-compute-runtime
        intel-media-driver
        vpl-gpu-rt
      ];
    };
    networking.firewall = globals.mkFirewallRules {
      service = "jellyfin";
      sources = [
        globals.networking.ipv4.lanSubnet
        globals.networking.ipv6.lanSubnet
      ];
      udpPorts = [ ports.discovery ];
    };
    services.caddy.virtualHosts."jf.${config.local.caddy.domain}" = {
      extraConfig = "reverse_proxy localhost:${toString ports.http}";
      useACMEHost = config.local.caddy.domain;
    };
    services.jellyfin = {
      enable = true;
      hardwareAcceleration = {
        device = "/dev/dri/renderD128";
        enable = true;
        type = "qsv";
      };
    };
    systemd.services.jellyfin = {
      environment.JELLYFIN_PublishedServerUrl = cfg.publishedServerUrl;
      unitConfig.RequiresMountsFor = [ "/mnt/media" ];
    };
    users.users.jellyfin.extraGroups = [
      "render"
      "video"
    ];
  };
}
