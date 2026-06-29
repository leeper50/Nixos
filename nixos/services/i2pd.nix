{ lib, config, ... }:
let
  cfg = config.local.i2pd;
in
{
  options.local.i2pd = {
    bandwidth = lib.mkOption {
      type = lib.types.int;
      default = 50000;
    };
    enableIPv6 = lib.mkEnableOption "ipv6";
    port = lib.mkOption {
      type = lib.types.int;
      default = 25565;
    };
    privateAddress = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
    };
    publicAddress = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
    };
  };
  config = lib.mkMerge [
    {
      networking.firewall = {
        allowedTCPPorts = [
          cfg.port
        ];
        allowedUDPPorts = [
          cfg.port
        ];
      };
      services.i2pd = {
        address = cfg.publicAddress;
        bandwidth = cfg.bandwidth;
        enable = true;
        enableIPv4 = true;
        enableIPv6 = cfg.enableIPv6;
        port = cfg.port;
        proto = {
          http = {
            address = cfg.privateAddress;
            enable = true;
            port = 7070;
          };
          httpProxy = {
            address = cfg.privateAddress;
            enable = true;
            port = 4444;
          };
          sam = {
            address = cfg.privateAddress;
            enable = true;
            port = 7656;
          };
          socksProxy = {
            address = cfg.privateAddress;
            enable = true;
            port = 4447;
          };
        };
      };
    }
  ];
}
