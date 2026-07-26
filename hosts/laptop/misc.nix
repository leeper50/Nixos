{ pkgs, ... }:
let
  creamlinux = import (pkgs.fetchFromGitHub {
    owner = "Novattz";
    repo = "creamlinux-installer";
    rev = "main";
    hash = "sha256-sV23mp0XnJHf4oSqqvFLFfvSkssHzxafqYMNw3HGEdg=";
  }) { inherit pkgs; };
  waifu2x-ncnn-vulkan = pkgs.stdenv.mkDerivation {
    name = "waifu2x-ncnn-vulkan";
    src = pkgs.fetchurl {
      url = "https://github.com/nihui/waifu2x-ncnn-vulkan/releases/download/20250915/waifu2x-ncnn-vulkan-20250915-linux.zip";
      sha256 = "848e0fba55657d34da90b775b8139e9806dc754798b029f95e106ba8850a731f";
    };
    nativeBuildInputs = [
      pkgs.autoPatchelfHook
      pkgs.makeWrapper
      pkgs.unzip
    ];
    buildInputs = [
      pkgs.stdenv.cc.cc.lib
      pkgs.vulkan-loader
    ];
    unpackPhase = "unzip $src";
    installPhase = ''
      cd waifu2x-ncnn-vulkan-20250915-linux
      mkdir -p $out/bin $out/share/waifu2x-ncnn-vulkan
      cp -r models-* $out/share/waifu2x-ncnn-vulkan/
      cp waifu2x-ncnn-vulkan $out/bin/
      wrapProgram $out/bin/waifu2x-ncnn-vulkan \
        --add-flags "-m $out/share/waifu2x-ncnn-vulkan/models-cunet" \
        --prefix LD_LIBRARY_PATH : ${pkgs.vulkan-loader}/lib
    '';
  };
in
{
  environment.systemPackages = [
    creamlinux
    waifu2x-ncnn-vulkan
  ];
}
