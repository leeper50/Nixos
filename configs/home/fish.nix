# All fish functions and aliases. Imported by configs/home/default.nix.
{
  config,
  globals,
  lib,
  pkgs,
  systemType,
  ...
}:
let
  cfg = config.local.fish;
  editor = if systemType == "Standalone" then "helix" else "hx";
  isDarwin = systemType == "NixDarwin";
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
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
  options.local.fish.gui.enable = lib.mkEnableOption "fish functions for systems with a GUI";

  config = lib.mkMerge [
    # All systems
    {
      home.shell.enableFishIntegration = true;
      programs = {
        eza.enableFishIntegration = true;
        fish = {
          functions = {
            build = ''
              git -C $NH_FLAKE pull;
              nh ${nhTarget} build${if systemType == "Standalone" then hmBackup else " --dry"}
            '';
            clean = if systemType == "Standalone" then "nh clean user" else "sudo nh clean all";
            fish_prompt = {
              description = "Write out the prompt";
              body = ''
                set -l last_pipestatus $pipestatus
                set -lx __fish_last_status $status # Export for __fish_print_pipestatus.
                set -l normal (set_color normal)

                # Color the prompt differently when we're root
                set -l color_cwd $fish_color_cwd
                set -l suffix '>'
                if functions -q fish_is_root_user; and fish_is_root_user
                    if set -q fish_color_cwd_root
                        set color_cwd $fish_color_cwd_root
                    end
                    set suffix '#'
                end

                # Write pipestatus
                # If the status was carried over (if no command is issued or if `set` leaves the status untouched), don't bold it.
                set -l bold_flag --bold
                set -q __fish_prompt_status_generation; or set -g __fish_prompt_status_generation $status_generation
                if test $__fish_prompt_status_generation = $status_generation
                    set bold_flag
                end
                set __fish_prompt_status_generation $status_generation
                set -l status_color (set_color $fish_color_status)
                set -l statusb_color (set_color $bold_flag $fish_color_status)
                set -l prompt_status (__fish_print_pipestatus "[" "]" "|" "$status_color" "$statusb_color" $last_pipestatus)

                echo -n -s (prompt_login)' ' (set_color $color_cwd) (prompt_pwd) $normal (fish_vcs_prompt) $normal " "$prompt_status $suffix " "
              '';
            };
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
        fzf.enableFishIntegration = true;
      };
    }
    (lib.mkIf config.programs.lf.enable {
      programs.fish.functions = {
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
      };
    })
    # GUI systems: image conversion helpers
    (lib.mkIf cfg.gui.enable {
      programs.direnv.enableFishIntegration = true;
      programs.fish.functions = {
        comp = ''
          set extensions avif jxl webp
          set time_results

          for ext in $extensions
              set start (date +%s.%N)
              conv $ext $argv >/dev/null 2>&1
              and mkdir -p $ext
              and mv *.$ext $ext/
              set end (date +%s.%N)
              set elapsed (printf "%.3f" (math "$end - $start"))
              set -a time_results "$elapsed seconds for $ext/"
          end

          set sorted_time (string join \n $time_results | sort -n)
          for item in $sorted_time
              echo $item
          end

          echo ""
          du -sh -- avif/ jxl/ webp/ | sort -h
        '';
        conv = ''
          argparse 'q=' d l delete -- $argv
          or return 1

          set format $argv[1]
          if test -z "$format"
              set format webp
          end

          set quality 90
          if set -q _flag_q
              set quality $_flag_q
          end

          set formats avif jxl webp
          if not contains $format $formats
              echo "Format must be specified: 'avif', 'jxl', or 'webp'."
              echo ""
              echo "Available flags:"
              echo "-d:       Decode format into png"
              echo "-l:       Encode as lossless"
              echo "-q <int>: Encode with quality value"
              echo "--delete: Delete source files"
              echo ""
              echo "Examples:"
              echo "'conv avif -l --delete' => Encodes lossless avif images and deletes the source files"
              echo "'conv jxl -q 60'        => Encodes lossy jpegxl images with a quality of 60"
              echo "'conv webp -d --delete' => Decodes webp images into pngs and deletes the source files"
              return 1
          end

          set inputs

          if set -q _flag_d
              echo "Decoding..."
              switch $format
                  case avif
                      set inputs avif
                      __mass_convert avif "avifdec {} {.}.png"
                  case jxl
                      set inputs jxl
                      __mass_convert jxl "djxl {} {.}.png"
                  case webp
                      set inputs webp
                      __mass_convert webp "dwebp {} -o {.}.png"
              end
          else
              echo "Encoding..."
              switch $format
                  case avif
                      set inputs jpeg jpg png y4m
                      if set -q _flag_l
                          __mass_convert $inputs "avifenc --lossless {} {.}.avif"
                      else
                          __mass_convert $inputs "avifenc --qcolor $quality --qalpha $quality {} {.}.avif"
                      end
                  case jxl
                      set inputs apng exr gif jpeg jpg pam pfm pgx png ppm
                      if set -q _flag_l
                          __mass_convert $inputs "cjxl --lossless_jpeg=1 -q 100 {} {.}.jxl"
                      else
                          __mass_convert $inputs "cjxl --lossless_jpeg=0 -q $quality {} {.}.jxl"
                      end
                  case webp
                      set inputs jpeg jpg pam pgm png pnm ppm tiff
                      if set -q _flag_l
                          __mass_convert $inputs "cwebp -lossless {} -o {.}.webp"
                      else
                          __mass_convert $inputs "cwebp -q $quality {} -o {.}.webp"
                      end
              end
          end

          if set -q _flag_delete
              __rm_ext $inputs
          end
        '';
        __mass_convert = ''
          set cmd $argv[-1]
          set ext_list $argv[1..-2]

          if test (count $ext_list) -eq 0
              echo "Usage: __mass_convert <ext>... <command>" >&2
              return 1
          end

          set fd_args
          for e in $ext_list
              set -a fd_args -e $e
          end

          set matching_files (fd -u -t f -0 $fd_args | string split0)

          if test (count $matching_files) -eq 0
              printf 'No matching files found for: %s\n' "$ext_list" >&2
              return 0
          end

          parallel -j 8 --bar --unsafe "$cmd > /dev/null 2>&1" ::: $matching_files

          echo "Jobs done"
        '';
        __rm_ext = ''
          for ext in $argv
              fd -u -t f -e "$ext" -X rm
          end
        '';
      };
    })
    # GUI systems, Linux only
    (lib.mkIf (cfg.gui.enable && !isDarwin) {
      programs.fish.functions = {
        autoclicker = ''
          sudo theclicker run -d /dev/input/event11 -c25 -C0 -l275 -H
        '';
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
              set -a args --proxy socks5h://node-1.${globals.domains.tailnet}:1080
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
          set -l dir .
          if set -q argv[1]
              set dir (string trim -r -c / -- $argv[1])
              test -n "$dir"; or set dir /
          end
          if not test -d "$dir"
              echo "rename_media: not a directory: $dir" >&2
              return 1
          end
          set -l exts avif bmp gif heic jpg jpeg jxl m4v mkv mp4 png tiff webp
          for file in $dir/*.*
              test -f "$file"; or continue
              set -l name (path basename -- "$file")
              set -l ext (string split -r -m1 . -- "$name")[2]
              contains -- (string lower -- "$ext") $exts; or continue
              set -l hash (md5sum -- "$file" | string split ' ')[1]
              if test "$name" != "$hash.$ext"
                  mv -n -- "$file" "$dir/$hash.$ext"
              end
          end
        '';
      };
    })
    # Aliases: all systems
    {
      programs.fish.shellAliases = {
        edit_nix = "cd ~/Nix && hx ~/Nix";
        hm = "home-manager --flake $NH_FLAKE";
        rcat = "${pkgs.coreutils}/bin/cat";
        rls = "${pkgs.coreutils}/bin/ls";
      };
    }
    (lib.mkIf config.programs.bat.enable {
      programs.fish.shellAliases.cat = "bat -pp";
    })
    (lib.mkIf config.programs.eza.enable {
      programs.fish.shellAliases.l = "eza";
    })
    (lib.mkIf config.programs.rclone.enable {
      programs.fish.shellAliases.ncdu = "rclone ncdu";
    })
    (lib.mkIf isLinux {
      programs.fish.shellAliases = {
        j = "journalctl";
        rs = "sudo systemctl";
        s = "systemctl";
        us = "systemctl --user";
      };
    })
    # Aliases: GUI systems
    (lib.mkIf cfg.gui.enable {
      programs.fish.shellAliases.cz = "chezmoi";
    })
    # Aliases: GUI systems, Linux only
    (lib.mkIf (cfg.gui.enable && !isDarwin) {
      programs.fish.shellAliases =
        let
          excludes = lib.strings.concatMapStringsSep " " (e: "--exclude ${e}") [
            ".DS_Store"
            ".stfolder"
            ".stignore"
          ];
          local = "$HOME/Pictures/Wallpapers/";
          remote = "Copyparty:/Tablet/";
        in
        {
          bisync = "rclone bisync -P ${local} ${remote} ${excludes} $argv";
          helix = "hx";
          pull = "rclone sync -P ${remote} ${local} ${excludes} $argv";
          push = "rclone sync -P ${local} ${remote} ${excludes} $argv";
        };
    })
    # Aliases: Plasma desktop
    (lib.mkIf (config.programs.plasma.enable or false) {
      programs.fish.shellAliases.repair_kde = "kbuildsycoca6 --noincremental && kquitapp6 plasmashell && kstart plasmashell";
    })
  ];
}
