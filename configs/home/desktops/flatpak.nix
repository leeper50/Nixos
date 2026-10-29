{ nix-flatpak, ... }:
{
  imports = [
    nix-flatpak.homeManagerModules.nix-flatpak
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
