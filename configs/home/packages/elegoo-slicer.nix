{
  config,
  lib,
  pkgs,
  systemType,
  ...
}:
let
  cfg = config.local.packages;
  hash = "sha256-X3ox1tpXAPddm2qgyBNajP/bIQr9fw61neeTAQTFsyM=";
  src = pkgs.fetchurl {
    hash = hash;
    url = "https://github.com/elegoo-repo/ElegooSlicer/releases/download/v${version}/ElegooSlicer_Linux_V${version}.AppImage";
  };
  version = "1.5.3.4";
  appimageContents = pkgs.appimageTools.extract {
    pname = "elegoo-slicer";
    inherit version src;
  };
  elegoo-slicer = pkgs.appimageTools.wrapType2 {
    pname = "elegoo-slicer";
    version = version;
    inherit src;
    extraPkgs = pkgs: [
      pkgs.webkitgtk_4_1
      pkgs.libsoup_3
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
