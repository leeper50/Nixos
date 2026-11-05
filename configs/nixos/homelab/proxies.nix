{
  lib,
  config,
  globals,
  options,
  pkgs,
  ...
}:
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
    microsocks.enable = lib.mkEnableOption "microsocks SOCKS5 proxy on the host's tailnet address";
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
          assertion = !(config.local.proxies.tor.enable && config.local.proxies.tor.name == "");
          message = "tor.name must be set when using tor.";
        }
      ];
    }
    (lib.mkIf config.local.proxies.i2p.enable {
      networking.firewall = {
        allowedTCPPorts = [
          config.local.proxies.i2p.port
        ];
        allowedUDPPorts = [
          config.local.proxies.i2p.port
        ];
      };
      services.i2pd = {
        enable = true;
        settings = {
          addressbook.subscriptions =
            "http://i2p-projekt.i2p/hosts.txt,"
            + "http://inr.i2p/export/alive-hosts.txt,"
            + "http://stats.i2p/cg";
          bandwidth = config.local.proxies.i2p.bandwidth;
          ipv4 = true;
          ipv6 = config.local.proxies.i2p.enableIPv6;
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
          port = config.local.proxies.i2p.port;
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
    (lib.mkIf config.local.proxies.microsocks.enable {
      services.microsocks = {
        enable = true;
        ip = globals.networking.tailnet.${config.networking.hostName}.ipv4;
      };
      systemd.services.microsocks = {
        after = [ "tailscaled.service" ];
        wants = [ "tailscaled.service" ];
        preStart = ''
          for _ in $(seq 60); do
            ${pkgs.iproute2}/bin/ip -o addr show | grep -qF " ${config.services.microsocks.ip}/" && exit 0
            sleep 1
          done
          echo "${config.services.microsocks.ip} not assigned after 60s" >&2
          exit 1
        '';
      };
    })
    (lib.mkIf config.local.proxies.tor.enable {
      services.tor = {
        enable = true;
        relay = {
          enable = true;
          role = "bridge";
        };
        settings = {
          ContactInfo = config.local.proxies.tor.email;
          ExitRelay = false;
          Nickname = config.local.proxies.tor.name;
          ORPort = config.local.proxies.tor.port;
          RelayBandwidthBurst = "200 KBytes";
          RelayBandwidthRate = "100 KBytes";
        };
      };
      networking.firewall.allowedTCPPorts = [ config.local.proxies.tor.port ];
      systemd.tmpfiles.rules = [
        "d /var/lib/tor 0750 tor tor -"
      ];
    })
    (lib.mkIf config.local.proxies.yggdrasil.enable {
      networking.firewall = {
        allowedTCPPorts = [
          config.local.proxies.yggdrasil.port
        ];
        allowedUDPPorts = [
          config.local.proxies.yggdrasil.port
        ];
      };
      services.yggdrasil = {
        enable = true;
        settings = {
          Listen =
            if config.local.proxies.yggdrasil.enableIPv6 then
              [
                "tcp://[::]:${toString config.local.proxies.yggdrasil.port}"
              ]
            else
              [
                "tcp://0.0.0.0:${toString config.local.proxies.yggdrasil.port}"
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
