{ lib, pkgs, ... }:
{
  imports = [ ./fish.nix ];
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
    stateVersion = "26.05";
    username = "walter";
  };
  programs = {
    bat.enable = true;
    eza = {
      colors = "always";
      enable = true;
      git = true;
      icons = "always";
    };
    fd.enable = true;
    fish.enable = true;
    fzf.enable = true;
    git = {
      enable = true;
      lfs.enable = true;
      signing = {
        format = "openpgp";
        key = "2F7A99CBD7D51B34F8921A6E6014E165D58C6C21";
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
