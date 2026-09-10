{ ... }:
let
  wireplumber_config = {
    "50-rename-sinks" = {
      "monitor.alsa.rules" = [
        {
          actions = {
            update-props = {
              "node.description" = "Builtin Audio";
              "node.nick" = "Builtin Audio";
            };
          };
          matches = [
            { "node.name" = "~alsa_output\\.pci-.*\\.analog-stereo"; }
          ];
        }
        {
          actions = {
            update-props = {
              "node.description" = "Headphones";
              "node.nick" = "Headphones";
            };
          };
          matches = [
            { "node.name" = "alsa_output.usb-FIIO_FiiO_K11-01.analog-stereo"; }
          ];
        }
        {
          actions = {
            update-props = {
              "node.description" = "Speakers";
              "node.nick" = "Speakers";
            };
          };
          matches = [
            { "node.name" = "~alsa_output\\.usb-Apple.*\\.analog-stereo"; }
          ];
        }
        {
          actions = {
            update-props = {
              "node.description" = "Wireless Headphones";
              "node.nick" = "Wireless Headphones";
            };
          };
          matches = [
            { "node.name" = "~alsa_output\\.usb-SteelSeries.*\\.analog-stereo"; }
          ];
        }
      ];
    };
    "51-bluez" = {
      "wireplumber.settings" = {
        "bluetooth.autoswitch-to-headset-profile" = false;
      };
    };
    "52-earfun-air-pro-4" = {
      "monitor.bluez.rules" = [
        {
          actions = {
            update-props = {
              "bluez5.a2dp.ldac.quality" = "hq";
              "bluez5.enable-sbc-xq" = true;
              "bluez5.enable-hw-volume" = true;
            };
          };
          matches = [
            { "device.name" = "bluez_card.70_5A_6F_6B_6D_DB"; }
          ];
        }
      ];
      "device.profile.priority.rules" = [
        {
          actions = {
            update-props = {
              priorities = [
                "a2dp-sink"
                "a2dp-sink-aac"
                "a2dp-sink-sbc_xq"
                "a2dp-sink-sbc"
              ];
            };
          };
          matches = [
            { "device.name" = "bluez_card.70_5A_6F_6B_6D_DB"; }
          ];
        }
      ];
    };
  };
in
{
  services.pipewire = {
    enable = true;
    wireplumber = {
      enable = true;
      configs = wireplumber_config;
    };
  };
}
