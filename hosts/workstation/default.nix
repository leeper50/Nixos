{ agenix, stylix, ... }:
let
  rootDir = ../..;
in
{
  imports =
    map (p: rootDir + p) [
      /secrets/agenix.nix
      /home/profiles/gui_linux.nix
      /stylix
      /syncthing/workstation.nix
    ]
    ++ [
      agenix.homeManagerModules.default
      stylix.homeModules.stylix
    ];
}
