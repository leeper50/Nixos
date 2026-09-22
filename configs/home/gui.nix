# Common settings for all systems with a GUI (desktops).
# May also have cli settings for desktop specific tasks.
{
  config,
  globals,
  hostName ? null,
  lib,
  osConfig ? null,
  pkgs,
  systemType,
  ...
}:
let
  nixdFlake = "(builtins.getFlake \"${config.home.homeDirectory}/Nix\")";
  nixdOptions =
    if systemType == "NixDarwin" then
      { darwin.expr = "${nixdFlake}.darwinConfigurations.macbook.options"; }
    else if systemType == "Standalone" then
      { home-manager.expr = "${nixdFlake}.homeConfigurations.${hostName}.options"; }
    else
      { nixos.expr = "${nixdFlake}.nixosConfigurations.${osConfig.networking.hostName}.options"; };
in
{
  imports = [
    ./accounts.nix
    ./browsers
    ./default.nix
    ./dev.nix
    ./games.nix
    ./rclone.nix
  ]
  ++ lib.optionals (systemType != "NixDarwin") [
    ./audio/easyeffects.nix
    ./audio/wireplumber.nix
    ./desktops/hyprland.nix
    ./desktops/noctalia.nix
    ./desktops/sway.nix
  ];
  config = lib.mkMerge [
    {
      fonts.fontconfig.enable = true;
      home = {
        packages = with pkgs; [
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
          remmina
          signal-desktop
        ];
        pointerCursor.enable = pkgs.stdenv.hostPlatform.isLinux;
      };
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
            map alt+left send_text all \x1b\x62
            map alt+right send_text all \x1b\x66
            map ctrl+left next_window
            map ctrl+right previous_window
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
              Port = globals.sshPort;
              ServerAliveCountMax = 3;
              ServerAliveInterval = 15;
              User = globals.username;
            };
            "gk55" = {
              HostName = "10.0.0.50";
              Port = 22;
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
              Port = 22;
              User = "root";
            };
            "racknerd".HostName = "107.174.237.4";
            "servercheap".HostName = "65.75.202.6";
            "tower" = {
              HostName = "10.0.0.51";
              Port = 22;
              User = "root";
            };
            "k3s-01".HostName = "10.0.2.1";
            "k3s-02".HostName = "10.0.2.2";
            "k3s-03".HostName = "10.0.2.3";
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
                "[json]" = {
                  "editor.defaultFormatter" = "vscode.json-language-features";
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
                "claudeCode.hideOnboarding" = true;
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
                "nix.serverPath" = "${pkgs.nixd}/bin/nixd";
                "nix.serverSettings".nixd = {
                  formatting.command = [ "${pkgs.nixfmt}/bin/nixfmt" ];
                  nixpkgs.expr = "import ${nixdFlake}.inputs.nixpkgs { }";
                  options = nixdOptions;
                };
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
    (lib.mkIf (systemType != "NixDarwin") {
      home.activation.removeStylixGtkFiles = (
        lib.hm.dag.entryBefore [ "writeBoundary" ] ''
          rm -f $HOME/.gtkrc-2.0 \
                $HOME/.config/gtk-3.0/gtk.css \
                $HOME/.config/gtk-3.0/settings.ini \
                $HOME/.config/gtk-4.0/gtk.css \
                $HOME/.config/gtk-4.0/settings.ini
        ''
      );
      # Get dolphin working with hyprland
      home.file.".config/menus/applications.menu".text = ''
        <!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN"
          "http://www.freedesktop.org/standards/menu-spec/menu-1.0.dtd">
        <Menu>
          <Name>Applications</Name>
          <DefaultAppDirs/>
          <DefaultDirectoryDirs/>
          <DefaultMergeDirs/>
        </Menu>
      '';
      home.packages = with pkgs; [
        bazaar
        blender
        collabora-desktop
        czkawka
        feishin
        ffmpeg-full
        freac
        gimp
        imgbrd-grabber
        kdePackages.kdenlive
        qt5.qttools
        qview
        sqlitebrowser
        theclicker
        vlc
        yubioath-flutter
        pulseaudio
      ];
      programs = {
        alacritty.settings = {
          env.WINIT_X11_SCALE_FACTOR = "1";
          window.class = {
            instance = "Alacritty";
            general = "Alacritty";
          };
        };
        fish = {
          functions = {
            crop = ''
              test -f "$argv[1]"; or return 1
              set stem (string split -r -m1 . "$argv[1]")[1]
              magick "$argv[1]" $argv[2..-1] -crop 16:9 +repage -quality 90 "$stem.png"
            '';
            dl = ''
              if not type -q yt-dlp
                  echo "yt-dlp not found"
                  return 127
              end
              argparse a f= i t p -- $argv
              or return 2
              set args
              if set -q _flag_a
                  set -a args -x --audio-format opus --audio-quality 0
              end
              if set -q _flag_i
                  set -a args --ignore-config
              end
              if set -q _flag_f
                  if not test -f "$_flag_f"
                      echo "Batch file not found: $_flag_f"
                      return 3
                  end
                  set -a args --batch-file $_flag_f
              end
              if set -q _flag_t
                  set -a args -o "%(title)s.%(ext)s"
              end
              if set -q _flag_p
                  set -a args --proxy socks5://komodo.local:1080
              end
              if test -z "$argv[1]"; and not set -q _flag_f
                  echo "Missing URL"
                  return 1
              end
              if test -n "$argv[1]"
                  set -a args $argv[1]
              end
              yt-dlp $args
              return $status
            '';
            rename_media = ''
              if not type -q md5sum
                  echo "md5sum not found"
                  return 127
              end
              for file in *.{avif,bmp,gif,heic,jpg,jpeg,jxl,m4v,mkv,mp4,png,tiff,webp}
                  test -f "$file"; or continue
                  set ext (string split -r -m1 . "$file")[2]
                  set hash (md5sum "$file" | string split ' ')[1]
                  if test "$file" != "$hash.$ext"
                      mv -n "$file" "$hash.$ext"
                  end
              end
            '';
            sound = lib.mkIf pkgs.stdenv.hostPlatform.isLinux ''
              switch $argv[1]
                case 44100 48000 96000 192000 384000
                  pw-metadata -n settings 0 clock.force-rate $argv[1]
                case '*'
                  echo "Error: '$argv[1]' is not a valid sample rate"
              end
            '';
          };
          shellAliases = {
            bisync = "rclone bisync -P $argv $HOME/Pictures/Temp/ Copyparty:/Tablet/ --exclude .DS_Store";
            helix = "hx";
            pull = "rclone sync -P $argv Copyparty:/Tablet/ $HOME/Pictures/Temp/ --exclude .DS_Store";
            push = "rclone sync -P $argv $HOME/Pictures/Temp/ Copyparty:/Tablet/ --exclude .DS_Store";
          };
        };
        mpv = {
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
          enable = true;
        };
        yt-dlp = {
          enable = true;
          extraConfig = ''
            # Output template
            -o "%(title)s.%(ext)s"
            # Filesystem options
            --mtime
            --restrict-filenames
            # Subtitle options
            --write-auto-subs
            --write-subs
            # Postprocessing options
            --compat-options no-keep-subs
            --embed-chapters
            --embed-info-json
            --embed-metadata
            --embed-subs
            --embed-thumbnail
            --xattrs
            # Sponsorblock options
            --sponsorblock-mark all
            --sponsorblock-remove interaction,intro,music_offtopic,preview,selfpromo,sponsor,outro
          '';
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
      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          # My stuff
          "inode/directory" = [
            "org.kde.dolphin.desktop"
            "Helix.desktop"
            "code.desktop"
          ];
        };
        defaultApplicationPackages = with pkgs; [
          audacious
          helix
          kdePackages.ark
          kdePackages.dolphin
          firefox
          qview
          gimp
          mpv
          thunderbird
          vscode
          zathura
        ];
      };
    })
    (lib.mkIf (systemType == "NixDarwin") {
      home = {
        activation = {
          setDefaultApps = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            ${pkgs.duti}/bin/duti -s com.interversehq.qView public.image viewer
          '';
        };
        packages = with pkgs; [
          dbgate
          duti
          libreoffice-bin
          vlc-bin
          wireguard-tools
        ];
      };
    })
  ];
}
