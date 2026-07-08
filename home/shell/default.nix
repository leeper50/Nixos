{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    file
    pistol
  ];
  programs = {
    bat.enable = true;
    eza = {
      enable = true;
      enableFishIntegration = true;
      extraOptions = [
        "--color"
      ];
      git = true;
      icons = "always";
    };
    fastfetch.enable = true;
    fd.enable = true;
    fish = {
      enable = true;
      shellInit = ''
        set fish_greeting
        set -gx EDITOR helix
        set -gx TERM xterm-256color
        set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
        set -gx MANROFFOPT -c
        set -gx XDG_CONFIG_DIRS "$XDG_CONFIG_DIRS:/etc/xdg"
        fish_add_path $HOME/.local/bin $HOME/.cargo/bin $HOME/.dotnet/tools $HOME/.bun/bin $HOME/go/bin
        set -gx FLAKE_DIR $HOME/Nix
        if type -q kubectl
          alias k kubectl
        end
      '';
      shellAliases = {
        cat = "bat -pp";
        cz = "chezmoi";
        edit_nix = "cd ~/Nix && hx ~/Nix";
        helix = "hx";
        hm = "home-manager --flake $FLAKE_DIR/.#(hostname)";
        l = "eza";
        ncdu = "rclone ncdu";
        rcat = "command cat";
        rs = "sudo systemctl";
        s = "systemctl";
        update_flake = "nix flake update --flake $FLAKE_DIR";
        us = "systemctl --user";
      };
      functions = {
        build = ''
          set original_dir (pwd)
          if type -q nixos-rebuild
            cd $FLAKE_DIR
            git pull
            sudo nixos-rebuild test --flake $FLAKE_DIR/.#(hostname)
            cd $original_dir
          else if type -q darwin-rebuild
            cd $FLAKE_DIR
            git pull
            sudo darwin-rebuild build --flake $FLAKE_DIR/.#(hostname)
            cd $original_dir
          else if type -q home-manager
            cd $FLAKE_DIR
            git pull
            home-manager build --flake $FLAKE_DIR/.#(hostname) -b home_manager_backup
            cd $original_dir
          else
            return 1
          end
        '';
        clean = ''
          if type -q nixos-rebuild; or type -q darwin-rebuild
            sudo nix-collect-garbage -d
          else if type -q home-manager
            nix-collect-garbage -d
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
        lf = ''
          set tmp_file "$HOME/.cache/lf-lastdir"
          command lf --last-dir-path="$tmp_file" $argv
          if test -f $tmp_file
            set last_dir (cat $tmp_file)
            if test -d "$last_dir" -a "$last_dir" != (pwd)
              cd $last_dir
            end
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
            cd $FLAKE_DIR
            git pull
            home-manager switch --flake $FLAKE_DIR/.#(hostname) -b home_manager_backup
            cd $original_dir
          else
            return 1
          end
        '';
      };
    };
    fzf = {
      enable = true;
      enableFishIntegration = true;
    };
    git = {
      enable = true;
      lfs.enable = true;
      settings = {
        core.autocrlf = false;
        credential.helper = "store";
        init.defaultBranch = "main";
        user = {
          email = "wleeper13@outlook.com";
          name = "Walter Leeper";
        };
      };
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
    htop.enable = true;
    lf = {
      enable = true;
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
        icons = true;
      };
    };
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
  xdg.configFile."lf/icons".source = ./lf-icons;
}
