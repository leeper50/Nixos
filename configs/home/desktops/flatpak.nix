{ nix-flatpak, pkgs, ... }:
{
  imports = [
    nix-flatpak.homeManagerModules.nix-flatpak
  ];
  home.packages = [
    pkgs.bazaar
  ];
  services.flatpak = {
    enable = true;
    packages = [
      "io.freetubeapp.FreeTube"
      "org.jellyfin.JellyfinDesktop"
    ];
    uninstallUnmanaged = true;
    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };
  };
}
