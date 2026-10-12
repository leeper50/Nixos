{
  config,
  globals,
  lib,
  localLib,
  ...
}:
let
  cfg = config.local.bentopdf;
in
{
  options.local.bentopdf = {
    enable = lib.mkEnableOption "bentopdf";
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      services.bentopdf = {
        enable = true;
        domain = "pdf.${globals.domains.devicePrimary}";
      };
    })
    (lib.mkIf (cfg.enable && config.services.caddy.enable) {
      services.caddy.virtualHosts = localLib.mkCaddyVirtualHosts {
        pdf = ''
          root * ${config.services.bentopdf.package}
          try_files {path} /index.html
          file_server
        '';
      };
    })
  ];
}
