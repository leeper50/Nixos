{ lib, pkgs, ... }:
{
  gtk.gtk4.theme = null;
  home.packages =
    with pkgs;
    [
      _1password-gui
      bitwarden-cli
      bitwarden-desktop
      czkawka
      feishin
      ffmpeg-full
      fira-code
      fira-code-symbols
      fira-sans
      libavif
      libjxl
      libwebp
      mumble
      oxipng
      sqlitebrowser
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      audacious
      audacious-plugins
      deskflow
      easyeffects
      filezilla
      freac
      freetube
      gimp
      handbrake
      haruna
      libsForQt5.qt5.qttools
      qview
      teamspeak6-client
      (vivaldi.override {
        proprietaryCodecs = true;
      })
      vivaldi-ffmpeg-codecs
      vlc
      wowup-cf
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      gimp2
      vlc-bin
    ];
  programs = {
    alacritty = {
      enable = true;
      settings = {
        cursor = {
          style = "Underline";
          thickness = 0.15;
          unfocused_hollow = true;
        };
        env.TERM = "xterm-256color";
        scrolling = {
          history = 1000;
          multiplier = 3;
        };
        window = {
          blur = true;
          decorations = "full";
          decorations_theme_variant = "Dark";
          dimensions = {
            columns = 128;
            lines = 32;
          };
          dynamic_padding = true;
        };
      }
      // lib.optionalAttrs pkgs.stdenv.isLinux {
        env = {
          WINIT_X11_SCALE_FACTOR = "1";
        };
        window.class = {
          instance = "Alacritty";
          general = "Alacritty";
        };
      };
    };
    btop.enable = true;
    chromium = lib.mkIf pkgs.stdenv.isLinux {
      enable = true;
      extensions = [
        { id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa"; } # 1password
        { id = "dnhpnfgdlenaccegplpojghhmaamnnfp"; } # augmented steam
        { id = "ajopnjidmegmdimjlfnijceegpefgped"; } # betterttv
        { id = "ldpochfccmkkmhdbclfhpagapcfdljkj"; } # decentraleyes
        { id = "edibdbjcniadpccecjdfdjjppcpchdlm"; } # i-still-dont-care-about-cookies
        { id = "fkagelmloambgokoeokbpihmgpkbgbfm"; } # indie wiki buddy
        { id = "padekgcemlokbadohgkifijomclgjgif"; } # proxy switchyomega
        { id = "kbmfpngjjgdllneeigpgjifpgocmfgmb"; } # reddit enhancement suite
        { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock-origin
        { id = "jinjaccalgkegednnccohejagnlnfdag"; } # violent monkey
      ];
      package = pkgs.chromium;
    };
    joplin-desktop.enable = true;
    kitty = {
      enable = true;
      extraConfig = ''
        background_blur 1
        disable_ligatures always
        map ctrl+left next_window
        map ctrl+right previous_window
        map alt+left send_text all \x1b\x62
        map alt+right send_text all \x1b\x66
        symbol_map U+23FB-U+23FE,U+2665,U+26A1,U+2B58,U+E000-U+E00A,U+E0A0-U+E0A3,U+E0B0-U+E0C8,U+E0CA,U+E0CC-U+E0D2,U+E0D4,U+E0D6,U+E0D8,U+E0DA,U+E0DC,U+E0DE,U+E0E0-U+E0E3,U+E0E5,U+E0E7,U+E0E9-U+E0EE,U+F000-U+F2E0,U+F300-U+F31C,U+F400-U+F4A9,U+F500-U+F8FF Symbols Nerd Font Mono
      '';
      settings = {
        confirm_os_window_close = 0;
        enable_audio_bell = false;
        enabled_layouts = "splits:split_axis=auto";
        remember_window_size = "yes";
      };
    };
    mpv = lib.mkIf pkgs.stdenv.isLinux {
      enable = true;
      bindings = {
        DOWN = "add volume -2";
        LEFT = "seek -5";
        RIGHT = "seek 5";
        UP = "add volume 2";
      };
      config = {
        interpolation = true;
        loop-file = "inf";
        profile = "gpu-hq";
        video-sync = "display-resample";
        volume = 30;
      };
    };
    obsidian.enable = true;
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
    vscode = {
      enable = true;
      package = pkgs.vscodium;
      profiles = {
        default = {
          extensions = with pkgs.vscode-extensions; [
            anthropic.claude-code
            arrterian.nix-env-selector
            bradlc.vscode-tailwindcss
            dbaeumer.vscode-eslint
            esbenp.prettier-vscode
            golang.go
            jnoortheen.nix-ide
            matthewpi.caddyfile-support
            mkhl.direnv
            mkhl.shfmt
            ms-azuretools.vscode-containers
            ms-python.debugpy
            ms-python.python
            ndonfris.fish-lsp
            prisma.prisma
            rust-lang.rust-analyzer
            svelte.svelte-vscode
            tailscale.vscode-tailscale
            tamasfe.even-better-toml
            vadimcn.vscode-lldb
            vscode-icons-team.vscode-icons
          ];
          userSettings = {
            "[css]" = {
              "editor.defaultFormatter" = "vscode.css-language-features";
            };
            "[html]" = {
              "editor.defaultFormatter" = "vscode.html-language-features";
            };
            "[javascript]" = {
              "editor.defaultFormatter" = "vscode.typescript-language-features";
            };
            "[jsonc]" = {
              "editor.defaultFormatter" = "vscode.json-language-features";
            };
            "[typescript]" = {
              "editor.defaultFormatter" = "vscode.typescript-language-features";
            };
            "#js/ts.updateImportsOnFileMove.enabled" = "always";
            "claudeCode.preferredLocation" = "sidebar";
            "diffEditor.ignoreTrimWhitespace" = false;
            "editor.fontLigatures" = true;
            "files.associations" = {
              "*.css" = "tailwindcss";
            };
            "files.autoSave" = "afterDelay";
            "git.autofetch" = true;
            "git.confirmSync" = false;
            "git.enableSmartCommit" = true;
            "prettier.tabWidth" = 4;
            "prettier.useTabs" = true;
            "svelte.enable-ts-plugin" = true;
            "update.showReleaseNotes" = false;
            "vsicons.dontShowNewVersionMessage" = true;
            "workbench.iconTheme" = "vscode-icons";
            "workbench.startupEditor" = "none";
          };
        };
      };
    };
    zathura = {
      enable = true;
      mappings = {
        "<Left>" = "navigate previous";
        "<Right>" = "navigate next";
      };
      options = {
        adjust-window = "best-fit";
        pages-per-row = 2;
        recolor = true;
      };
    };
  };
  fonts.fontconfig.enable = true;
  stylix = {
    base16Scheme = "${pkgs.base16-schemes}/share/themes/monokai.yaml";
    enable = true;
    fonts = {
      serif = {
        package = pkgs.liberation_ttf;
        name = "Liberation Serif";
      };
      sansSerif = {
        package = pkgs.fira-sans;
        name = "Fira Sans";
      };
      monospace = {
        package = pkgs.fira-code;
        name = "Fira Code";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };
    icons = lib.mkIf pkgs.stdenv.isLinux {
      enable = true;
      package = pkgs.papirus-icon-theme;
      dark = "Papirus-Dark";
    };
    image = ./wallpaper.jxl;
    targets = {
      firefox = {
        colorTheme.enable = true;
        profileNames = [ "default" ];
      };
      gtk.enable = true;
    };
    opacity.terminal = 0.8;
  };
}
