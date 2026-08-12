{ lib, pkgs, ... }:
{
  imports = [
    ./gui.nix
    ../desktop/hyprland.nix
  ];
  home.activation.removeStylixGtkFiles = (
    lib.hm.dag.entryBefore [ "writeBoundary" ] ''
      rm -f $HOME/.gtkrc-2.0 \
            $HOME/.config/gtk-3.0/gtk.css \
            $HOME/.config/gtk-3.0/settings.ini \
            $HOME/.config/gtk-4.0/gtk.css \
            $HOME/.config/gtk-4.0/settings.ini
    ''
  );
  home.packages = with pkgs; [
    bazaar
    blender
    collabora-desktop
    czkawka
    deskflow
    feishin
    ffmpeg-full
    freac
    gimp
    kdePackages.kdenlive
    imgbrd-grabber
    qt5.qttools
    qview
    sqlitebrowser
    theclicker
    vlc
  ];
  programs = {
    alacritty.settings = {
      env.WINIT_X11_SCALE_FACTOR = "1";
      window.class = {
        instance = "Alacritty";
        general = "Alacritty";
      };
    };
    chromium = {
      enable = true;
      extensions = [
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
      package = pkgs.brave;
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
        bisync = "rclone bisync -P $argv $HOME/Pictures/Temp/ Copyparty:/Tablet/ --exclude .DS_Store";
        cat = "bat -pp";
        cz = "chezmoi";
        edit_nix = "cd ~/Nix && hx ~/Nix";
        helix = "hx";
        hm = "home-manager --flake $FLAKE_DIR/.#(hostname)";
        l = "eza";
        ncdu = "rclone ncdu";
        pull = "rclone sync -P $argv Copyparty:/Tablet/ $HOME/Pictures/Temp/ --exclude .DS_Store";
        push = "rclone sync -P $argv $HOME/Pictures/Temp/ Copyparty:/Tablet/ --exclude .DS_Store";
        rcat = "command cat";
        rs = "sudo systemctl";
        s = "systemctl";
        update_flake = "nix flake update --flake $FLAKE_DIR";
        us = "systemctl --user";
      };
    };
    mpv = {
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
