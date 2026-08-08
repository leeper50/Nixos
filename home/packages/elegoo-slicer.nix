{
  config,
  lib,
  pkgs,
  systemType,
  ...
}:
let
  cfg = config.local.packages;
  version = "1.5.3.4";
  hash = "sha256-X3ox1tpXAPddm2qgyBNajP/bIQr9fw61neeTAQTFsyM=";
  elegoo-slicer = pkgs.appimageTools.wrapType2 {
    pname = "elegoo-slicer";
    version = version;
    src = pkgs.fetchurl {
      url = "https://github.com/elegoo-repo/ElegooSlicer/releases/download/v${version}/ElegooSlicer_Linux_V${version}.AppImage";
      hash = hash;
    };
  };
in
{
  options.local.packages.elegoo-slicer.enable = lib.mkEnableOption "elegoo-slicer";
  config = lib.mkIf cfg.elegoo-slicer.enable (
    if systemType == "Standalone" then
      { home.packages = [ elegoo-slicer ]; }
    else
      { environment.systemPackages = [ elegoo-slicer ]; }
  );
}
