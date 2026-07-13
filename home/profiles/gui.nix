{ pkgs, ... }:
{
  imports = [
    ../accounts
    ../desktop
    ../dev
    ../firefox
    ../games
    ../default.nix
  ];
  home.packages = with pkgs; [
    file
    pistol
  ];
  programs = {
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
  };
}
