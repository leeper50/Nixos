{
  config,
  globals,
  lib,
  localLib,
  ...
}:
{
  options.local.bentopdf = {
    enable = lib.mkEnableOption "bentopdf";
  };
  config = lib.mkMerge [
    (lib.mkIf config.local.bentopdf.enable {
      services.bentopdf = {
        enable = true;
        domain = "pdf.${globals.domains.devicePrimary}";
      };
    })
    (lib.mkIf (config.local.bentopdf.enable && config.services.caddy.enable) {
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
