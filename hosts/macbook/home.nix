{ agenix, globals, ... }:
let
  rootDir = ../..;
in
{
  imports =
    map (p: rootDir + p) [
      /home/profiles/gui.nix
      /secrets
      /syncthing
    ]
    ++ [
      agenix.homeManagerModules.default
    ];
  local = {
    browsers = {
      brave.enable = true;
      firefox.enable = true;
      librewolf.enable = true;
    };
    syncthing = {
      folders = {
        "Desktops".enable = true;
        "Downloads".enable = true;
        "GlobalShare".enable = true;
        "Notes".enable = true;
        "Phone".enable = true;
        "Tablet".enable = true;
      };
      home = "/Users/${globals.username}";
    };
  };
}
