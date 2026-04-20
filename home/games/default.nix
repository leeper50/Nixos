{ lib, pkgs, ... }:
let
  retroarch_dir = "~/Sync/Retroarch";
in
{
  home.packages =
    with pkgs;
    [
      azahar
      dolphin-emu
      eden
      mumble
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      cemu
      faugus-launcher
      protonplus
      protontricks
      rpcs3
      ryubing
      teamspeak6-client
      wowup-cf
      xenia-canary
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
    retroarch = {
      enable = true;
      cores = {
        bsnes-hd.enable = true;
        citra.enable = true;
        desmume.enable = true;
        dolphin.enable = true;
        flycast.enable = true;
        genesis-plus-gx.enable = true;
        mesen.enable = true;
        mgba.enable = true;
        mupen64plus.enable = true;
        pcsx2.enable = true;
        ppsspp.enable = true;
        swanstation.enable = true;
      };
      package = pkgs.retroarch-bare;
      settings = {
        menu_use_preferred_system_color_theme = "false";
        netplay_nickname = "Ishyaboi";
        video_driver = "vulkan";
        video_fullscreen = "true";
        menu_driver = "xmb";
        xmb_menu_color_theme = "1";
        xmb_theme = "2";
        # Paths
        content_database_path = "${retroarch_dir}/ContentDatabase";
        cheat_database_path = "${retroarch_dir}/Cheats";
        playlist_directory = "${retroarch_dir}/Playlists";
        rgui_browser_directory = "${retroarch_dir}/Games";
        rgui_config_directory = "${retroarch_dir}/Config";
        savefile_directory = "${retroarch_dir}/Saves";
        savestate_directory = "${retroarch_dir}/States";
        screenshot_directory = "${retroarch_dir}/Screenshots";
        system_directory = "${retroarch_dir}/Bios";
        thumbnails_directory = "${retroarch_dir}/Thumbnails";
      };
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
