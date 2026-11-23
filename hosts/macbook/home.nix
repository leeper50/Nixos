{
  agenix,
  lib,
  pkgs,
  profile,
  secrets,
  ...
}:
{
  imports = [
    (import ../../configs/home { inherit lib pkgs profile; })
    ../../configs/home/syncthing.nix
    "${secrets}/default.nix"
    agenix.homeManagerModules.default
  ];
  local = {
    browsers = {
      chromium.enable = false;
      firefox.enable = true;
      librewolf.enable = true;
    };
    syncthing = {
      enable = true;
      home = "/Users/walter";
    };
  };
}
