{ pkgs, ... }:
{
  imports = [
    ./gui.nix
    ../desktop/hyprland.nix
  ];
  programs = {
    fish = {
      functions = {
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
      };
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
        # Preset aliases
        -t mkv
      '';
    };
  };
  xdg.mimeApps = {
    enable = true;
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
    defaultApplications = {
      # My stuff
      "inode/directory" = [
        "org.kde.dolphin.desktop"
        "Helix.desktop"
        "code.desktop"
      ];
    };
  };
}
