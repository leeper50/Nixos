{ lib, pkgs, ... }:
let
  colors = {
    background = "rgb(39, 40, 34)";
    blue = "rgb(102, 217, 239)";
    green = "rgb(166, 226, 46)";
    orange = "rgb(253, 151, 31)";
    pink = "rgb(249, 36, 114)";
    selectionBg = "rgba(39, 40, 34, 0.8)";
    selectionFg = "rgba(248, 248, 242, 0.8)";
    white = "rgb(248, 248, 242)";
    yellow = "rgb(230, 219, 116)";
  };
in
{
  gtk.gtk4.theme = null;
  home.packages =
    with pkgs;
    [
      _1password-gui
      bitwarden-cli
      bitwarden-desktop
      btop
      czkawka
      ffmpeg-full
      joplin-desktop
      libavif
      libjxl
      libwebp
      mumble
      obsidian
      oxipng
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      libsForQt5.qt5.qttools
      audacious
      audacious-plugins
      deskflow
      feishin
      filezilla
      freetube
      gimp
      haruna
      qview
      teamspeak6-client
      (vivaldi.override {
        proprietaryCodecs = true;
      })
      vivaldi-ffmpeg-codecs
      vlc
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
          TERM = "xterm-256color";
          WINIT_X11_SCALE_FACTOR = "1";
        };
        window.class = {
          instance = "Alacritty";
          general = "Alacritty";
        };
      };
    };

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

    kitty = {
      enable = true;
      extraConfig = ''
        map ctrl+left next_window
        map ctrl+right previous_window
        map alt+left send_text all \x1b\x62
        map alt+right send_text all \x1b\x66
      '';
      settings = {
        confirm_os_window_close = 0;
        enable_audio_bell = false;
        enabled_layouts = "splits:split_axis=auto";
        remember_window_size = "yes";
      };
      themeFile = "Monokai";
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

    zathura = lib.mkIf pkgs.stdenv.isLinux {
      enable = true;
      options = {
        completion-bg = lib.mkForce colors.background;
        completion-fg = lib.mkForce colors.white;
        completion-group-bg = lib.mkForce colors.background;
        completion-group-fg = lib.mkForce colors.green;
        completion-highlight-bg = lib.mkForce colors.selectionFg;
        completion-highlight-fg = lib.mkForce colors.selectionBg;
        default-bg = lib.mkForce colors.background;
        default-fg = lib.mkForce colors.white;
        highlight-active-color = lib.mkForce colors.selectionFg;
        highlight-color = lib.mkForce colors.selectionBg;
        inputbar-bg = lib.mkForce colors.background;
        inputbar-fg = lib.mkForce colors.white;
        notification-bg = lib.mkForce colors.background;
        notification-error-bg = lib.mkForce colors.background;
        notification-error-fg = lib.mkForce colors.pink;
        notification-fg = lib.mkForce colors.blue;
        notification-warning-bg = lib.mkForce colors.background;
        notification-warning-fg = lib.mkForce colors.white;
        recolor = lib.mkForce true;
        recolor-darkcolor = lib.mkForce colors.white;
        recolor-keephue = lib.mkForce true;
        recolor-lightcolor = lib.mkForce colors.background;
        render-loading = lib.mkForce true;
        render-loading-bg = lib.mkForce colors.background;
        render-loading-fg = lib.mkForce colors.white;
        statusbar-bg = lib.mkForce colors.background;
        statusbar-fg = lib.mkForce colors.white;
      };
    };
  };

  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/monokai.yaml";
    fonts = {
      serif = {
        package = pkgs.liberation_ttf;
        name = "Liberation Serif";
      };
      sansSerif = {
        package = pkgs.fira;
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
    targets.gtk.enable = true;
    icons = lib.mkIf pkgs.stdenv.isLinux {
      enable = true;
      package = pkgs.papirus-icon-theme;
      dark = "Papirus-Dark";
    };
  };
}
