{
  config,
  lib,
  pkgs,
  systemType,
  ...
}:
let
  cfg = config.local.packages;
  hash = "sha256-ezs/CODQ1Ru0cshYZdG+mwwoOFQj2rocsMOyJdAQGvw=";
  src = pkgs.fetchurl {
    hash = hash;
    url = "https://github.com/elegoo-repo/ElegooSlicer/releases/download/v${version}/ElegooSlicer_Linux_V${version}.AppImage";
  };
  version = "1.5.3.5";
  appimageContents = pkgs.appimageTools.extract {
    pname = "elegoo-slicer";
    inherit version src;
  };
  elegoo-slicer = pkgs.appimageTools.wrapType2 {
    pname = "elegoo-slicer";
    inherit version;
    inherit src;
    extraPkgs = pkgs: [
      pkgs.libsoup_3
      pkgs.webkitgtk_4_1
    ];
    extraInstallCommands = ''
      install -Dm444 ${appimageContents}/ElegooSlicer.png $out/share/pixmaps/elegoo-slicer.png
    '';
  };
  elegoo-slicer-desktop = pkgs.makeDesktopItem {
    name = "elegoo-slicer";
    desktopName = "ElegooSlicer";
    exec = "elegoo-slicer %F";
    icon = "elegoo-slicer";
    categories = [ "Utility" ];
    mimeTypes = [
      "model/stl"
      "application/vnd.ms-3mfdocument"
      "application/prs.wavefront-obj"
      "application/x-amf"
    ];
  };
in
{
  options.local.packages.elegoo-slicer.enable = lib.mkEnableOption "elegoo-slicer";
  config = lib.mkIf cfg.elegoo-slicer.enable (
    if systemType == "Standalone" then
      {
        home.packages = [
          elegoo-slicer
          elegoo-slicer-desktop
        ];
      }
    else
      {
        environment.systemPackages = [
          elegoo-slicer
          elegoo-slicer-desktop
        ];
      }
  );
}
