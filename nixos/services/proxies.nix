{
  lib,
  config,
  options,
  ...
}:
let
  cfg = config.local.proxies;
in
{
  options.local.proxies = {
    i2p = {
      bandwidth = lib.mkOption {
        type =
          (options.services.i2pd.settings.type.getSubOptions [
            "services"
            "i2pd"
            "settings"
          ]).bandwidth.type;
        default = "X";
      };
      enable = lib.mkEnableOption "i2p";
      enableIPv6 = lib.mkEnableOption "ipv6";
      port = lib.mkOption {
        type = lib.types.int;
        default = 25565;
      };
    };
    tor = {
      email = lib.mkOption {
        type = lib.types.str;
        default = "dellhplaptop@pm.me";
      };
      enable = lib.mkEnableOption "tor";
      name = lib.mkOption {
        type = lib.types.str;
        default = "";
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 9001;
      };
    };
    yggdrasil = {
      enable = lib.mkEnableOption "yggdrasil";
      enableIPv6 = lib.mkEnableOption "ipv6";
      port = lib.mkOption {
        type = lib.types.port;
        default = 9001;
      };
    };
  };
  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !(cfg.tor.enable && cfg.tor.name == "");
          message = "tor.name must be set when using tor.";
        }
      ];
    }
    (lib.mkIf cfg.i2p.enable {
      networking.firewall = {
        allowedTCPPorts = [
          cfg.i2p.port
        ];
        allowedUDPPorts = [
          cfg.i2p.port
        ];
      };
      services.i2pd = {
        enable = true;
        settings = {
          addressbook.subscriptions =
            "http://i2p-projekt.i2p/hosts.txt,"
            + "http://inr.i2p/export/alive-hosts.txt,"
            + "http://stats.i2p/cg";
          bandwidth = cfg.i2p.bandwidth;
          ipv4 = true;
          ipv6 = cfg.i2p.enableIPv6;
          http = {
            address = "0.0.0.0";
            enabled = true;
            port = 7070;
            strictheaders = false;
          };
          httpproxy = {
            address = "0.0.0.0";
            enabled = true;
            port = 4444;
          };
          port = cfg.i2p.port;
          sam = {
            address = "0.0.0.0";
            enabled = true;
            port = 7656;
          };
          socksproxy = {
            address = "0.0.0.0";
            enabled = true;
            port = 4447;
          };
        };
      };
    })
    (lib.mkIf cfg.tor.enable {
      services.tor = {
        enable = true;
        relay = {
          enable = true;
          role = "bridge";
        };
        settings = {
          ContactInfo = cfg.tor.email;
          ExitRelay = false;
          Nickname = cfg.tor.name;
          ORPort = cfg.tor.port;
          RelayBandwidthBurst = "200 KBytes";
          RelayBandwidthRate = "100 KBytes";
        };
      };
      networking.firewall.allowedTCPPorts = [ cfg.tor.port ];
      systemd.tmpfiles.rules = [
        "d /var/lib/tor 0750 tor tor -"
      ];
    })
    (lib.mkIf cfg.yggdrasil.enable {
      networking.firewall = {
        allowedTCPPorts = [
          cfg.yggdrasil.port
        ];
        allowedUDPPorts = [
          cfg.yggdrasil.port
        ];
      };
      services.yggdrasil = {
        enable = true;
        settings = {
          Listen =
            if cfg.yggdrasil.enableIPv6 then
              [
                "tcp://[::]:${toString cfg.yggdrasil.port}"
              ]
            else
              [
                "tcp://0.0.0.0:${toString cfg.yggdrasil.port}"
              ];
          Peers = [
            "quic://mo.us.ygg.triplebit.org:443"
            "tcp://ygg.everypizza.im:9441"
            "tls://31.22.111.195:32000"
          ];
          persistentKeys = true;
        };
      };
    })
  ];
}
