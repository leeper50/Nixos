{ globals, lib, pkgs, ... }:
let
  editor = if pkgs.stdenv.isLinux then "hx" else "helix";
in
{
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
      shellAliases = lib.mkMerge [
        {
          cat = "bat -pp";
          cz = "chezmoi";
          edit_nix = "cd ~/Nix && hx ~/Nix";
          hm = "home-manager --flake $FLAKE_DIR/.#(hostname)";
          l = "eza";
          ncdu = "rclone ncdu";
          rcat = "command cat";
          update_flake = "nix flake update --flake $FLAKE_DIR";
        }
        (lib.mkIf pkgs.stdenv.isLinux {
          rs = "sudo systemctl";
          s = "systemctl";
          us = "systemctl --user";
        })
      ];
      shellInit = ''
        set fish_greeting
        set -gx EDITOR ${editor}
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
          email = globals.primaryEmail;
          name = globals.fullName;
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
      settings.icons = true;
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
  };
  xdg.configFile."lf/icons".source = ./lf-icons;
}
