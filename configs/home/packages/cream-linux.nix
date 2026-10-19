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
    hash = "sha256-E8oJ073yhtFiCMVuixPvQbdYJNSTxu7ICTGMuq+jce8=";
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
