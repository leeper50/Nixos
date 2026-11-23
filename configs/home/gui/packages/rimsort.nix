{
  config,
  lib,
  pkgs,
  systemType,
  ...
}:
let
  hash = "sha256-wsdjJotUa6bfp81AbuEehmzExtVOavgy7fUFejLUfHw=";
  src = pkgs.fetchurl {
    hash = hash;
    url = "https://github.com/RimSort/RimSort/releases/download/v${version}/RimSort-v${version}-x86_64.AppImage";
  };
  version = "1.17.4";
  appimageContents = pkgs.appimageTools.extract {
    pname = "rimsort";
    inherit version src;
  };
  rimsort = pkgs.appimageTools.wrapType2 {
    pname = "rimsort";
    version = version;
    inherit src;
    extraPkgs = pkgs: [
      pkgs.libxkbfile
      pkgs.zstd
    ];
    extraInstallCommands = ''
      install -Dm444 -t $out/share/applications \
        ${appimageContents}/usr/share/applications/io.github.rimsort.RimSort.desktop
      substituteInPlace $out/share/applications/io.github.rimsort.RimSort.desktop \
        --replace-fail 'Exec=RimSort' 'Exec=rimsort'
      cp -r ${appimageContents}/usr/share/icons $out/share
    '';
  };
in
{
  options.local.packages.rimsort.enable = lib.mkEnableOption "rimsort";
  config = lib.mkIf config.local.packages.rimsort.enable (
    if systemType == "Standalone" then
      {
        home.packages = [ rimsort ];
      }
    else
      {
        environment.systemPackages = [ rimsort ];
      }
  );
}
