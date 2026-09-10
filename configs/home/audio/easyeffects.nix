{ lib, ... }:
let
  autoload = {
    "alsa_output.usb-Apple__Inc._USB-C_to_3.5mm_Headphone_Jack_Adapter_DWH148508H7JKLTAW-00.analog-stereo" =
      {
        device-description = "Speakers";
        device-profile = "Headphones";
        preset-name = "Flip Channels";
      };
    "alsa_output.usb-FIIO_FiiO_K11-01.analog-stereo" = {
      device-description = "Headphones";
      device-profile = "Analog Output";
      preset-name = "HD 6XX";
    };
    "bluez_output.70_5A_6F_6B_6D_DB.1" = {
      device-description = "EarFun Air Pro 4";
      device-profile = "Headphones";
      preset-name = "EarFun Air Pro 4";
    };
  };
in
{
  services.easyeffects = {
    enable = true;
    settings = {
      StreamInputs = {
        inputDevice = "alsa_input.usb-Samson_Technologies_Samson_Q2U_Microphone-00.analog-stereo";
        plugins = "rnnoise#0";
      };
      StreamOutputs.plugins = "equalizer#0";
      Window = {
        autostartOnLogin = true;
        outputAutoloadingFallbackPreset = "Default";
        outputAutoloadingUsesFallback = true;
      };
    };
  };
  xdg.dataFile = lib.mapAttrs' (
    device: settings:
    lib.nameValuePair "easyeffects/autoload/output/${device}:${settings.device-profile}.json" {
      text = builtins.toJSON ({ inherit device; } // settings);
    }
  ) autoload;
}
