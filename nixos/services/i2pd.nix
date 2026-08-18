{
  lib,
  config,
  options,
  ...
}:
let
  cfg = config.local.i2pd;
in
{
  options.local.i2pd = {
    bandwidth = lib.mkOption {
      type =
        (options.services.i2pd.settings.type.getSubOptions [
          "services"
          "i2pd"
          "settings"
        ]).bandwidth.type;
      default = "X";
    };
    enable = lib.mkEnableOption "i2pd";
    enableIPv6 = lib.mkEnableOption "ipv6";
    port = lib.mkOption {
      type = lib.types.int;
      default = 25565;
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      networking.firewall = {
        allowedTCPPorts = [
          cfg.port
        ];
        allowedUDPPorts = [
          cfg.port
        ];
      };
      services.i2pd = {
        settings = {
          bandwidth = cfg.bandwidth;
          ipv4 = true;
          ipv6 = cfg.enableIPv6;
          port = cfg.port;
          http = {
            enabled = true;
            address = "0.0.0.0";
            port = 7070;
            strictheaders = false;
          };
          httpproxy = {
            enabled = true;
            address = "0.0.0.0";
            port = 4444;
          };
          sam = {
            enabled = true;
            address = "0.0.0.0";
            port = 7656;
          };
          socksproxy = {
            enabled = true;
            address = "0.0.0.0";
            port = 4447;
          };
        };
        enable = true;
      };
    })
  ];
}
