{
  config,
  lib,
  pkgs,
  systemType,
  ...
}:
let
  buildInputs = [
    pkgs.alsa-lib
    pkgs.libxkbcommon
    pkgs.openssl
    pkgs.stdenv.cc.cc.lib
    pkgs.udev
    pkgs.vulkan-loader
    pkgs.wayland
  ];
  sha256 = "4c8882a214680fdab8d85b9fc26606052f4d9985580748dd9ef130be2b76007e";
  version = "0.8.1";
  nvforever = pkgs.stdenv.mkDerivation {
    inherit buildInputs;
    installPhase = ''
      cd NVForever-v${version}-x86_64-unknown-linux-gnu
      mkdir -p $out/bin $out/share/nvforever
      cp -r * $out/share/nvforever
      ln -sf $out/share/nvforever/nvforever $out/bin/nvforever
    '';
    name = "nvforever";
    nativeBuildInputs = [
      pkgs.autoPatchelfHook
      pkgs.makeWrapper
      pkgs.coreutils
    ];
    postFixup = ''
      wrapProgram $out/bin/nvforever \
        --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath buildInputs}
    '';

    src = pkgs.fetchurl {
      inherit sha256;
      url = "https://github.com/LootJunkieAzza/NVForever/releases/download/v${version}/NVForever-v0.8.1-x86_64-unknown-linux-gnu.tar.gz";
    };
    unpackPhase = "tar -xf $src";
  };
in
{
  options.local.packages.nvforever.enable = lib.mkEnableOption "nvforever";
  config = lib.mkIf config.local.packages.nvforever.enable (
    if systemType == "Standalone" then
      { home.packages = [ nvforever ]; }
    else
      { environment.systemPackages = [ nvforever ]; }
  );
}
