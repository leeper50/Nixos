# Common settings for all systems with a GUI (desktops).
# May also have cli settings for desktop specific tasks.
{
  globals,
  pkgs,
  ...
}:
{
  imports = [
    ../accounts.nix
    ../browsers
    ../default.nix
    ../dev.nix
    ../games.nix
    ../rclone.nix
  ];
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    chezmoi
    colmena
    corefonts
    file
    fira-code
    fira-code-symbols
    fira-sans
    keepassxc
    libavif
    libjxl
    libwebp
    nixd
    nixfmt
    oxipng
    pistol
    signal-desktop
  ];
  home.pointerCursor.enable = pkgs.stdenv.hostPlatform.isLinux;
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
      };
    };
    btop.enable = true;
    fastfetch.enable = true;
    fish.shellAliases = {
      colmena = "colmena --config $FLAKE_DIR/flake.nix";
      cz = "chezmoi";
      update_flake = "nix flake update --flake $FLAKE_DIR";
    };
    git.settings = {
      core.autocrlf = false;
      credential.helper = "store";
      init.defaultBranch = "main";
      user = {
        email = globals.primaryEmail;
        name = globals.fullName;
      };
    };
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
    lf = {
      previewer.source = pkgs.writeShellScript "pv.sh" ''
        #!/bin/sh
        file="$1"
        w="$2"
        h="$3"
        x="$4"
        y="$5"
        draw() {
          kitten icat --stdin no --transfer-mode memory --place "''${w}x''${h}@''${x}x''${y}" "$1" </dev/null >/dev/tty
          exit 1
        }
        case "$(file -Lb --mime-type "$file")" in 
          image/*)
            draw "$file"
            ;;
        esac
        pistol "$file"
      '';
      settings = {
        cleaner = "${pkgs.writeShellScript "lf-cleaner.sh" ''
          kitten icat --clear --stdin no --transfer-mode memory </dev/null >/dev/tty
        ''}";
      };
    };
    obsidian.enable = true;
    ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "*" = {
          AddKeysToAgent = "no";
          Compression = false;
          ControlMaster = "auto";
          ControlPath = "~/.ssh/master-%r@%n:%p";
          ControlPersist = "10m";
          ForwardAgent = false;
          HashKnownHosts = false;
          IdentityFile = "~/.ssh/id_ed25519";
          ServerAliveCountMax = 3;
          ServerAliveInterval = 15;
          User = globals.username;
        };
        "gk55" = {
          HostName = "10.0.0.50";
          User = "root";
        };
        "hetzner" = {
          HostName = "u400147.your-storagebox.de";
          Port = 23;
          User = "u400147";
        };
        "komodo".HostName = "komodo.local";
        "laptop".HostName = "laptop.local";
        "nas".HostName = "nas.local";
        "node-1".HostName = "node-1.local";
        "node-2".HostName = "node-2.local";
        "node-3".HostName = "node-3.local";
        "proxmox" = {
          HostName = "10.0.0.30";
          User = "root";
        };
        "racknerd".HostName = "107.174.237.4";
        "servercheap".HostName = "65.75.202.6";
        "tower" = {
          HostName = "10.0.0.51";
          User = "root";
        };
      };
    };
    vscode = {
      enable = true;
      profiles = {
        default = {
          extensions = with pkgs.vscode-extensions; [
            anthropic.claude-code
            arrterian.nix-env-selector
            bradlc.vscode-tailwindcss
            charliermarsh.ruff
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
            saoudrizwan.claude-dev
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
            "[yaml]" = {
              "prettier.tabWidth" = 2;
              "prettier.useTabs" = false;
            };
            "claudeCode.preferredLocation" = "panel";
            "diffEditor.ignoreTrimWhitespace" = false;
            "editor.fontLigatures" = true;
            "editor.formatOnSave" = false;
            "extensions.ignoreRecommendations" = true;
            "files.associations" = {
              "*.css" = "tailwindcss";
            };
            "files.autoSave" = "afterDelay";
            "git.autofetch" = true;
            "git.autoStash" = true;
            "git.confirmSync" = false;
            "git.enableSmartCommit" = true;
            "git.fetchOnPull" = true;
            "js/ts.updateImportsOnFileMove.enabled" = "always";
            "nix.enableLanguageServer" = true;
            "nix.serverPath" = "nixd";
            "prettier.tabWidth" = 4;
            "prettier.useTabs" = true;
            "svelte.enable-ts-plugin" = true;
            "telemetry.telemetryLevel" = "error";
            "terminal.integrated.initialHint" = false;
            "update.showReleaseNotes" = false;
            "vsicons.dontShowNewVersionMessage" = true;
            "workbench.iconTheme" = "vscode-icons";
            "workbench.secondarySideBar.defaultVisibility" = "hidden";
            "workbench.startupEditor" = "none";
          };
        };
      };
    };
  };
}
