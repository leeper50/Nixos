# On NixOS this is imported as a NixOS module: it sets up steam and hands the
# Home Manager settings to walter. Elsewhere it's a plain Home Manager module.
{
  config,
  lib,
  pkgs,
  systemType,
  ...
}:
let
  isNixos = systemType == "Nixos";
  forWalter =
    if isNixos then
      homeConfig: { home-manager.users.walter = lib.mkIf config.local.users.walter.enable homeConfig; }
    else
      homeConfig: homeConfig;
  retroarch_dir = "~/Sync/Retroarch";
in
{
  options.local.games = {
    emulators = {
      enable = lib.mkEnableOption "enable emulators";
      list = lib.mkOption {
        description = ''
          A list of nix packages containing
          emulators to be installed.'';
        default = with pkgs; [
          azahar
          cemu
          eden
          rpcs3
          shadps4-qtlauncher
          xdvdfs-cli
          xemu
          xenia-canary
        ];
        type = lib.types.listOf lib.types.package;
      };
    };
  };
  config = lib.mkMerge [
    (lib.optionalAttrs isNixos {
      programs.steam = {
        enable = true;
        extest.enable = true;
        extraCompatPackages = with pkgs; [
          proton-ge-bin
        ];
        extraPackages = with pkgs; [
          gamescope
        ];
        gamescopeSession.enable = true;
        localNetworkGameTransfers.openFirewall = true;
        protontricks.enable = true;
        remotePlay.openFirewall = true;
      };
    })
    (forWalter {
      home.packages = [
        pkgs.mumble
      ]
      ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
        pkgs.r2modman
        pkgs.wowup-cf
      ]
      ++ lib.optionals isNixos [
        pkgs.heroic
      ]
      ++ lib.optionals (
        pkgs.stdenv.hostPlatform.isLinux && config.local.games.emulators.enable
      ) config.local.games.emulators.list;
      programs = {
        lutris = lib.mkIf isNixos {
          enable = true;
          # Proton through umu by default; plain wine for games that need it.
          defaultWinePackage = pkgs.proton-ge-bin;
          extraPackages = with pkgs; [
            gamescope
            mangohud
            umu-launcher
            winetricks
          ];
          protonPackages = [ pkgs.proton-ge-bin ];
          steamPackage = config.programs.steam.package;
          winePackages = [ pkgs.wineWow64Packages.stagingFull ];
        };
        prismlauncher.enable = pkgs.stdenv.hostPlatform.isLinux;
        retroarch = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux && config.local.games.emulators.enable) {
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
    })
  ];
}
