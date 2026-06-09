{ lib, pkgs, ... }:
{
  stylix = {
    base16Scheme = "${pkgs.base16-schemes}/share/themes/monokai.yaml";
    enable = true;
    cursor = {
      name = "Qogir Cursors";
      package = pkgs.qogir-icon-theme;
      size = 32;
    };
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
    };
    icons = lib.mkIf pkgs.stdenv.isLinux {
      dark = "Papirus-Dark";
      enable = true;
      package = pkgs.papirus-icon-theme;
    };
    image = ./wallpaper.jxl;
    opacity.terminal = 0.8;
    targets.gtk.enable = lib.mkIf pkgs.stdenv.isLinux true;
  };
}
