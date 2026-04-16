{ plasma-manager, pkgs, ... }:
{
  imports = [
    plasma-manager.homeModules.plasma-manager
  ];
  home.packages = with pkgs; [ nixos-icons ];
  programs.fish.shellAliases = {
    "repair_kde" = "kbuildsycoca6 --noincremental && kquitapp6 plasmashell && kstart plasmashell";
  };
  programs.plasma = {
    enable = true;
    input.keyboard = {
      numlockOnStartup = "on";
    };
    kscreenlocker = {
      appearance.wallpaper = ./wallpaper.jxl;
      autoLock = false;
    };
    kwin = {
      effects = {
        blur = {
          enable = true;
          noiseStrength = 1;
          strength = 10;
        };
        shakeCursor.enable = false;
        zoom.enable = false;
      };
      cornerBarrier = true;
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
              hidden = [
                "org.kde.plasma.clipboard"
              ];
              shown = [
                "org.kde.plasma.battery"
                "org.kde.plasma.bluetooth"
                "org.kde.plasma.networkmanagement"
                "org.kde.plasma.volume"
              ];
            };
          }
          {
            digitalClock = {
              calendar.firstDayOfWeek = "sunday";
              date = {
                enable = true;
                format = "isoDate";
                position = "adaptive";
              };
              time.format = "24h";
            };
          }
        ];
      }
    ];
    powerdevil = {
      AC = {
        autoSuspend.action = "nothing";
        dimDisplay.enable = false;
        powerButtonAction = "showLogoutScreen";
        powerProfile = "powerSaving";
        turnOffDisplay.idleTimeout = "never";
      };
      battery = {
        autoSuspend.action = "nothing";
        dimDisplay.enable = false;
        powerButtonAction = "showLogoutScreen";
        powerProfile = "powerSaving";
        turnOffDisplay.idleTimeout = "never";
      };
      lowBattery = {
        autoSuspend.action = "nothing";
        dimDisplay.enable = false;
        powerButtonAction = "showLogoutScreen";
        powerProfile = "powerSaving";
        turnOffDisplay.idleTimeout = "never";
      };
    };
    session = {
      general = {
        askForConfirmationOnLogout = true;
      };
      sessionRestore = {
        restoreOpenApplicationsOnLogin = "startWithEmptySession";
      };
    };
    shortcuts = {
      "kmix" = {
        "mic_mute" = [
          "Meta+Shift+A"
          "Microphone Mute"
        ];
      };
      "kwin" = {
        "Show Desktop" = [ ];
      };
      "plasmashell" = {
        "show dashboard" = [ ];
      };
    };
    workspace = {
      iconTheme = "Papirus-Dark";
      splashScreen.theme = "None";
    };
  };
}
