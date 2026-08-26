{
  lib,
  options,
  pkgs,
  ...
}:
{
  config = lib.mkMerge (
    [
      {
        stylix = {
          base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
          enable = true;
          fonts = {
            emoji = {
              name = "Noto Color Emoji";
              package = pkgs.noto-fonts-color-emoji;
            };
            monospace = {
              name = "Fira Code";
              package = pkgs.fira-code;
            };
            sansSerif = {
              name = "Fira Sans";
              package = pkgs.fira-sans;
            };
            serif = {
              name = "Liberation Serif";
              package = pkgs.liberation_ttf;
            };
            sizes = {
              applications = 14;
              desktop = 14;
            };
          };
          image = ./wallpaper.jxl;
        };
      }
    ]
    ++ lib.optionals (options.stylix ? cursor) [
      {
        stylix.cursor = {
          name = "Qogir Cursors";
          package = pkgs.qogir-icon-theme;
          size = 32;
        };
        stylix.icons = {
          dark = "Papirus-Dark";
          enable = true;
          package = pkgs.papirus-icon-theme;
        };
        stylix.targets.gtk.enable = true;
      }
    ]
  );
}
