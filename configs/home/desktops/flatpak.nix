{ nix-flatpak, pkgs, ... }:
let
  pdfcraft_version = "0.15.0";
  pdfcraft_sha256 = "sha256-RvKBx9t8mkIjUD7UmwE3G9Ls7W+cyXycFRfcQdBQKeY=";
  photocraft_version = "0.17.0";
  photocraft_sha256 = "sha256-yW3AzBDLHbJp2sog1KJUm/aVDFFL59aLjcJtVXRAFjc=";
in
{
  imports = [
    nix-flatpak.homeManagerModules.nix-flatpak
  ];
  services.flatpak = {
    enable = true;
    packages = [
      rec {
        appId = "ai.storyteller.photocraft";
        sha256 = photocraft_sha256;
        bundle = "${pkgs.fetchurl {
          url = "https://github.com/storytold/photocraft/releases/download/v${photocraft_version}/photocraft-${photocraft_version}-linux-x86_64.flatpak";
          inherit sha256;
        }}";
      }
      rec {
        appId = "ai.storyteller.pdfcraft";
        sha256 = pdfcraft_sha256;
        bundle = "${pkgs.fetchurl {
          url = "https://github.com/storytold/pdfcraft/releases/download/v${pdfcraft_version}/pdfcraft-${pdfcraft_version}-linux-x86_64.flatpak";
          inherit sha256;
        }}";
      }
      "com.parsecgaming.parsec"
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
