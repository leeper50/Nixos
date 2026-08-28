{ lib, pkgs, ... }:
let
  enableEmulators = false;
  retroarch_dir = "~/Sync/Retroarch";
in
{
  home.packages =
    with pkgs;
    [
      discord
      mumble
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      limo
      openmw
      # teamspeak6-client
      # wowup-cf
    ]
    ++ lib.optionals (pkgs.stdenv.hostPlatform.isLinux && enableEmulators) [
      azahar
      dolphin-emu
      eden
      ryubing
      xenia-canary
    ];
  programs = {
    prismlauncher.enable = pkgs.stdenv.hostPlatform.isLinux;
    retroarch = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux && enableEmulators) {
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
        menu_driver = "xmb";
        menu_use_preferred_system_color_theme = "false";
        netplay_nickname = "Ishyaboi";
        video_driver = "vulkan";
        video_fullscreen = "true";
        xmb_menu_color_theme = "1";
        xmb_theme = "2";
        # Paths
        audio_filter_dir = "${retroarch_dir}/Filters/Audio";
        cheat_database_path = "${retroarch_dir}/Cheats";
        content_database_path = "${retroarch_dir}/ContentDatabase";
        playlist_directory = "${retroarch_dir}/Playlists";
        rgui_browser_directory = "${retroarch_dir}/Games";
        rgui_config_directory = "${retroarch_dir}/Config";
        savefile_directory = "${retroarch_dir}/Saves";
        savestate_directory = "${retroarch_dir}/States";
        screenshot_directory = "${retroarch_dir}/Screenshots";
        system_directory = "${retroarch_dir}/Bios";
        thumbnails_directory = "${retroarch_dir}/Thumbnails";
        video_filter_dir = "${retroarch_dir}/Filters/Video";
        video_shader_dir = "${retroarch_dir}/Shaders";
      };
    };
    vesktop = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
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
