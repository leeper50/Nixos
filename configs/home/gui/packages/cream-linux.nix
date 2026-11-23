{
  config,
  lib,
  pkgs,
  systemType,
  ...
}:
let
  hash = "sha256-78NexMKBlJltCGb1qDK4B2kYNMdVAWNxgSUDnNjOJhM=";
  src = pkgs.fetchFromGitHub {
    hash = hash;
    owner = "Novattz";
    repo = "creamlinux-installer";
    rev = "v${version}";
  };
  version = "1.8.0";
  creamlinux = import src { inherit pkgs; };
in
{
  options.local.packages.cream-linux.enable = lib.mkEnableOption "cream-linux";
  config = lib.mkIf config.local.packages.cream-linux.enable (
    if systemType == "Standalone" then
      { home.packages = [ creamlinux ]; }
    else
      { environment.systemPackages = [ creamlinux ]; }
  );
}
