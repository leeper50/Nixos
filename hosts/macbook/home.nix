{ globals, ... }:
let
  rootDir = ../..;
in
{
  imports = map (p: rootDir + p) [
    /syncthing
  ];
  local.syncthing = {
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
}
