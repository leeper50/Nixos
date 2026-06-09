{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    awww
    hyprpaper
    mpvpaper
  ];
}
