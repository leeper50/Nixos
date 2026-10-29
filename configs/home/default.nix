{
  config,
  globals,
  lib,
  pkgs,
  systemType,
  ...
}:
let
  editor = if systemType == "Standalone" then "helix" else "hx";
  signingKey = globals.sshKeys.email;
  nhTarget =
    {
      Nixos = "os";
      NixDarwin = "darwin";
      Standalone = "home";
    }
    .${systemType};
  hmBackup = lib.optionalString (systemType == "Standalone") " -b home_manager_backup";
in
{
  home = {
    homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin then "/Users/walter" else "/home/walter";
    packages =
      with pkgs;
      [
        age
        base16-schemes
        bc
        chezmoi
        iperf
        powerline-fonts
      ]
      ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
        hwinfo
        trashy
      ];
    shell.enableFishIntegration = true;
    stateVersion = "26.05";
    username = "walter";
  };
  programs = {
    bat.enable = true;
    eza = {
      colors = "always";
      enable = true;
      enableFishIntegration = true;
      git = true;
      icons = "always";
    };
    fd.enable = true;
    fish = {
      enable = true;
      functions = {
        build = ''
          git -C $NH_FLAKE pull;
          nh ${nhTarget} build${if systemType == "Standalone" then hmBackup else " --dry"}
        '';
        clean = if systemType == "Standalone" then "nh clean user" else "sudo nh clean all";
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
          ${lib.optionalString (systemType == "Nixos") "sudo "}git -C $NH_FLAKE pull;
          nh ${nhTarget} switch${hmBackup}
        '';
      };
      plugins = [
        {
          name = "plugin-git";
          src = pkgs.fishPlugins.plugin-git.src;
        }
      ];
      shellAliases = lib.mkMerge [
        {
          cat = "bat -pp";
          edit_nix = "cd ~/Nix && hx ~/Nix";
          hm = "home-manager --flake $NH_FLAKE";
          l = "eza";
          rcat = "${pkgs.coreutils}/bin/cat";
          rls = "${pkgs.coreutils}/bin/ls";
        }
        (lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          j = "journalctl";
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
        set -gx XDG_CONFIG_HOME ${config.xdg.configHome}
        fish_add_path $HOME/.local/bin $HOME/.cargo/bin $HOME/.dotnet/tools $HOME/.bun/bin $HOME/go/bin
        set -gx NH_FLAKE $HOME/Nix
      '';
    };
    fzf = {
      enable = true;
      enableFishIntegration = true;
    };
    git = {
      enable = true;
      lfs.enable = true;
      settings.gpg.ssh.allowedSignersFile = toString (
        pkgs.writeText "allowed_signers" ''
          ${globals.primaryEmail} namespaces="git" ${signingKey}
        ''
      );
      signing = {
        format = "ssh";
        key = signingKey;
        signByDefault = true;
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
    home-manager.enable = true;
    htop.enable = true;
    nh = {
      clean = {
        enable = true;
        extraArgs = "--keep-since 4d --keep 3";
      };
      enable = true;
      flake = "$NH_FLAKE";
    };
    jq.enable = true;
    lf = {
      enable = true;
      settings.icons = true;
    };
    parallel = {
      enable = true;
      will-cite = true;
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
  targets.genericLinux.enable = pkgs.stdenv.hostPlatform.isLinux;
  xdg.configFile."lf/icons".source = ./lf-icons;
}
