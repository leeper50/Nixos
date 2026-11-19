{
  config,
  globals,
  lib,
  localLib,
  secrets,
  ...
}:
let
  cfg = config.local.homeassistant;
  ports = {
    mqtt = 1883;
    zigbee2mqtt = 8099;
  };
in
{
  options.local.homeassistant = {
    mosquitto.enable = lib.mkEnableOption "the mosquitto MQTT broker";
    zigbee2mqtt = {
      adapter = lib.mkOption {
        default = "zstack";
        description = "Zigbee adapter type (zstack for TI chips, ember for Silicon Labs).";
        type = lib.types.enum [
          "deconz"
          "ember"
          "zboss"
          "zigate"
          "zoh"
          "zstack"
        ];
      };
      enable = lib.mkEnableOption "zigbee2mqtt";
      serialPort = lib.mkOption {
        default = "/dev/serial/by-id/usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_0c001b4aa9e7ec11a0a97a60e89bdf6f-if00-port0";
        description = "Zigbee adapter, by its stable /dev/serial/by-id path.";
        type = lib.types.str;
      };
      network = {
        channel = lib.mkOption {
          default = 20;
          type = lib.types.ints.between 11 26;
        };
        extPanId = lib.mkOption {
          default = [
            195
            189
            251
            23
            158
            174
            134
            176
          ];
          type = lib.types.listOf lib.types.ints.u8;
        };
        panId = lib.mkOption {
          default = 22682;
          type = lib.types.ints.u16;
        };
      };
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.mosquitto.enable {
      local.restic.backups.services = {
        paths = [ "/var/lib/mosquitto" ];
        user = "root";
      };
      networking.firewall = localLib.mkFirewallRules {
        service = "mosquitto";
        sources = globals.networking.docker.subnets;
        tcpPorts = [ ports.mqtt ];
      };
      services.mosquitto = {
        enable = true;
        listeners = [
          {
            acl = [ "topic readwrite #" ];
            omitPasswordAuth = true;
            port = ports.mqtt;
            settings.allow_anonymous = true;
          }
        ];
      };
    })
    (lib.mkIf cfg.zigbee2mqtt.enable {
      age.secrets."zigbee2mqtt_secret.age" = {
        file = "${secrets}/zigbee2mqtt_secret.age";
        owner = "zigbee2mqtt";
      };
      local.restic.backups.services = {
        exclude = [ "/var/lib/zigbee2mqtt/log" ];
        paths = [ "/var/lib/zigbee2mqtt" ];
        user = "root";
      };
      services.zigbee2mqtt = {
        enable = true;
        settings = {
          advanced = {
            channel = cfg.zigbee2mqtt.network.channel;
            ext_pan_id = cfg.zigbee2mqtt.network.extPanId;
            log_output = [ "console" ];
            network_key = "!secret network_key";
            pan_id = cfg.zigbee2mqtt.network.panId;
          };
          frontend = {
            enabled = true;
            host = "127.0.0.1";
            port = ports.zigbee2mqtt;
          };
          homeassistant.enabled = true;
          serial = {
            inherit (cfg.zigbee2mqtt) adapter;
            port = cfg.zigbee2mqtt.serialPort;
          };
          # The module rewrites configuration.yaml on every start; without a
          # version Zigbee2MQTT re-runs its settings migrations each time.
          version = 5;
        };
      };
      systemd = {
        services.zigbee2mqtt = lib.mkIf cfg.mosquitto.enable {
          after = [ "mosquitto.service" ];
          requires = [ "mosquitto.service" ];
        };
        tmpfiles.rules = [
          "L+ /var/lib/zigbee2mqtt/secret.yaml - - - - ${config.age.secrets."zigbee2mqtt_secret.age".path}"
        ];
      };
    })
    (lib.mkIf (cfg.zigbee2mqtt.enable && config.services.caddy.enable) {
      services.caddy.virtualHosts = localLib.mkCaddyVirtualHosts {
        zb = "reverse_proxy 127.0.0.1:${toString ports.zigbee2mqtt}";
      };
    })
  ];
}
