{ plasma-manager, pkgs, ... }:
{
  imports = [
    plasma-manager.homeModules.plasma-manager
  ];
  home.packages = with pkgs; [ nixos-icons ];
  programs.plasma = {
    enable = true;
    kwin = {
      effects = {
        blur = {
          enable = true;
          noiseStrength = 5;
          strength = 15;
        };
      };
      cornerBarrier = false;
      edgeBarrier = 0;
    };
    panels = [
      {
        height = 48;
        location = "bottom";
        screen = 0;
        widgets = [
          {
            kickoff = {
              sortAlphabetically = true;
              icon = "nix-snowflake-white";
            };
          }
          {
            iconTasks = {
              launchers = [
                "applications:vivaldi-stable.desktop"
                "applications:org.kde.dolphin.desktop"
                "applications:kitty.desktop"
                "applications:codium.desktop"
                "applications:systemsettings.desktop"
              ];
            };
          }
          "org.kde.plasma.marginsseparator"
          {
            systemTray.items = {
              shown = [
                "org.kde.plasma.networkmanagement"
                "org.kde.plasma.volume"
              ];
              hidden = [
                "org.kde.plasma.battery"
                "org.kde.plasma.bluetooth"
              ];
            };
          }
          {
            digitalClock = {
              calendar.firstDayOfWeek = "sunday";
              time.format = "24h";
            };
          }
        ];
      }
    ];
    workspace = {
      iconTheme = "Papirus-Dark";
    };
  };
}
