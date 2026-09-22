{ agenix, globals, ... }:
let
  rootDir = ../..;
in
{
  imports =
    map (p: rootDir + p) [
      /configs/home/gui.nix
      /configs/home/syncthing.nix
      /secrets
    ]
    ++ [
      agenix.homeManagerModules.default
    ];
  local = {
    browsers = {
      brave.enable = false;
      firefox.enable = true;
      librewolf.enable = true;
    };
    syncthing = {
      folders = {
        "Desktops".enable = true;
        "Downloads".enable = true;
        "FreeTube".enable = true;
        "GlobalShare".enable = true;
        "Notes".enable = true;
        "Phone".enable = true;
        "Tablet".enable = true;
      };
      home = "/Users/${globals.username}";
    };
  };
}
