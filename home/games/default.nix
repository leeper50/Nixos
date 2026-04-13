{ lib, pkgs, ... }:
{
  home.packages =
    with pkgs;
    [
      mumble
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      faugus-launcher
      protonplus
      protontricks
      teamspeak6-client
      wowup-cf
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
    ];
  programs = {
    lutris = lib.mkIf pkgs.stdenv.isLinux {
      enable = true;
      protonPackages = [ pkgs.proton-ge-bin ];
      winePackages = [ pkgs.wineWow64Packages.full ];
    };
    prismlauncher = lib.mkIf pkgs.stdenv.isLinux {
      enable = true;
    };
    vesktop = lib.mkIf pkgs.stdenv.isLinux {
      enable = true;
      settings = {
        arRPC = false;
        clickTrayToShowHide = true;
        discordBranch = "stable";
        hardwareAcceleration = true;
        hardwareVideoAcceleration = true;
        minimizeToTray = true;
        tray = true;
      };
      vencord = {
        settings = {
          autoUpdate = false;
          autoUpdateNotification = false;
          notifyAboutUpdates = false;
          plugins = {
            AnonymiseFileNames.enabled = true;
            CtrlEnterSend.enabled = true;
            Dearrow.enabled = true;
            FakeNitro.enabled = true;
            FixImagesQuality.enabled = true;
            ShowMeYourName.enabled = true;
            SilentTyping.enabled = true;
            VoiceChatDoubleClick.enabled = true;
            VolumeBooster.enabled = true;
            YoutubeAdblock.enabled = true;
          };
          useQuickCss = true;
        };
      };
    };
  };
}
