{ agenix, secrets, ... }:
let
  rootDir = ../..;
in
{
  imports =
    map (p: rootDir + p) [
      /configs/home/gui.nix
      /configs/home/syncthing.nix
    ]
    ++ [
      "${secrets}/default.nix"
      agenix.homeManagerModules.default
    ];
  local = {
    browsers = {
      brave.enable = false;
      firefox.enable = true;
      librewolf.enable = true;
    };
    syncthing.home = "/Users/walter";
  };
}
