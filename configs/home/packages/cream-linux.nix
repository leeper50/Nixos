{
  config,
  lib,
  pkgs,
  systemType,
  ...
}:
let
  cfg = config.local.packages;
  creamlinux = import (pkgs.fetchFromGitHub {
    hash = "sha256-sV23mp0XnJHf4oSqqvFLFfvSkssHzxafqYMNw3HGEdg=";
    owner = "Novattz";
    repo = "creamlinux-installer";
    rev = "main";
  }) { inherit pkgs; };
in
{
  options.local.packages.cream-linux.enable = lib.mkEnableOption "cream-linux";
  config = lib.mkIf cfg.cream-linux.enable (
    if systemType == "Standalone" then
      { home.packages = [ creamlinux ]; }
    else
      { environment.systemPackages = [ creamlinux ]; }
  );
}
