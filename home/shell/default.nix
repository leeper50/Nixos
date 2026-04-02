{ lib, pkgs, ... }:
{
  programs = {
    bat.enable = true;
    eza = {
      enable = true;
      git = true;
      icons = "always";
    };
    fastfetch.enable = true;
    fd.enable = true;
    fish = {
      enable = true;
      shellInit = ''
        set fish_greeting
        set -gx EDITOR hx
        set -gx TERM xterm-256color
        set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
        set -gx MANROFFOPT -c
        fish_add_path $HOME/.local/bin $HOME/.cargo/bin $HOME/.dotnet/tools $HOME/.bun/bin $HOME/go/bin
        if type -q nixos-rebuild
            set -gx FLAKE_DIR /etc/nixos
        else
            set -gx FLAKE_DIR $HOME/Nix
        end
      '';
      shellAliases = {
        cat = "bat -pp";
        clean = "nix-collect-garbage";
        cz = "chezmoi";
        helix = "hx";
        hm = "home-manager --flake $FLAKE_DIR/.#(hostname)";
        l = "eza --color --git --icons";
        la = "eza --color --git --icons -a";
        ncdu = "rclone ncdu";
        rcat = "command cat";
        rs = "sudo systemctl";
        s = "systemctl";
      };
      functions = {
        build = ''
          set original_dir (pwd)
          if type -q nixos-rebuild
              cd $FLAKE_DIR
              sudo git pull
              sudo nixos-rebuild test --flake $FLAKE_DIR/.#(hostname)
              cd $original_dir
          else if type -q darwin-rebuild
              cd $FLAKE_DIR
              git pull
              sudo darwin-rebuild build --flake $FLAKE_DIR/.#(hostname)
              cd $original_dir
          else if type -q home-manager
              set unmanaged_files \
                  ~/.gtkrc-2.0 \
                  ~/.config/gtk-3.0/gtk.css \
                  ~/.config/gtk-3.0/settings.ini \
                  ~/.config/gtk-4.0/gtk.css \
                  ~/.config/gtk-4.0/settings.ini
              rm -f $unmanaged_files
              cd $FLAKE_DIR
              git pull
              home-manager build --flake $FLAKE_DIR/.#(hostname) -b home_manager_backup
              cd $original_dir
          else
              return 1
          end
        '';
        dl = ''
          if type -q yt-dlp
              argparse a i t p -- $argv
              or return 1

              set args

              if set -q _flag_a
                  set -a args -x --audio-format opus --audio-quality 0
              end
              if set -q _flag_i
                  set -a args --ignore-config
              end
              if set -q _flag_t
                  set -a args -o "%(title)s.%(ext)s"
              end
              if set -q _flag_p
                  set -a args --proxy socks5://komodo:1080
              end

              if test -z "$argv[1]"
                  echo "Missing URL"
                  return 1
              end

              set -a args $argv[1]
              yt-dlp $args
          else
              echo "yt-dlp not found"
              return 1
          end
        '';
        sound = ''
          if test (uname -s) = Linux
              switch $argv[1]
                  case 44100 48000 96000 192000 384000
                      pw-metadata -n settings 0 clock.force-rate $argv[1]
                  case '*'
                      echo "Error: '$argv[1]' is not a valid sample rate"
              end
          else
              echo "Unsupported OS"
              return 1
          end
        '';
        update = ''
          set original_dir (pwd)
          if type -q nixos-rebuild
              cd $FLAKE_DIR
              sudo git pull
              sudo nixos-rebuild switch --flake $FLAKE_DIR/.#(hostname)
              cd $original_dir
          else if type -q darwin-rebuild
              cd $FLAKE_DIR
              git pull
              sudo darwin-rebuild switch --flake $FLAKE_DIR/.#(hostname)
              cd $original_dir
          else if type -q home-manager
              set unmanaged_files \
                  ~/.gtkrc-2.0 \
                  ~/.config/gtk-3.0/gtk.css \
                  ~/.config/gtk-3.0/settings.ini \
                  ~/.config/gtk-4.0/gtk.css \
                  ~/.config/gtk-4.0/settings.ini
              rm -f $unmanaged_files
              cd $FLAKE_DIR
              git pull
              home-manager switch --flake $FLAKE_DIR/.#(hostname) -b home_manager_backup
              cd $original_dir
          else
              return 1
          end
        '';
        update_flake = ''
          nix flake update --flake $FLAKE_DIR
        '';
      };
    };
    fzf = {
      enable = true;
      enableFishIntegration = true;
    };
    helix = {
      enable = true;
      languages = {
        language = [
          {
            auto-format = true;
            formatter.command = "nixfmt";
            name = "nix";
          }
        ];
      };
      settings = {
        editor = {
          mouse = false;
          shell = [
            "fish"
            "-c"
          ];
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
          file-picker.hidden = false;
          statusline = {
            left = [
              "mode"
              "spinner"
            ];
            center = [
              "file-name"
              "read-only-indicator"
              "file-modification-indicator"
              "version-control"
            ];
            mode = {
              normal = "Normal";
              insert = "Editing";
              select = "Selecting";
            };
          };
        };
        keys.normal = {
          "j" = "move_char_left";
          "k" = "move_visual_line_down";
          "l" = "move_visual_line_up";
          ";" = "move_char_right";
        };
      };
    };
    git = {
      enable = true;
      lfs.enable = true;
      settings = {
        core.autocrlf = false;
        init.defaultBranch = "main";
        user = {
          email = "wleeper13@outlook.com";
          name = "Walter Leeper";
        };
      };
    };
    htop.enable = true;
    ripgrep.enable = true;
    tealdeer = {
      enable = true;
      settings = {
        updates = {
          auto_update = true;
          auto_update_interval_hours = 24;
        };
      };
    };
    yt-dlp = lib.mkIf pkgs.stdenv.isLinux {
      enable = true;
      extraConfig = ''
        # Output template
        -o "%(title)s.%(ext)s"
        # Filesystem options
        --cookies-from-browser vivaldi+kwallet6
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
        # Preset aliases
        -t mkv
      '';
    };
  };
  programs.home-manager.enable = true;
}
