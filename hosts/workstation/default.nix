{ agenix, stylix, ... }:
let
  rootDir = ../..;
in
{
  imports =
    map (p: rootDir + p) [
      /secrets/agenix.nix
      /home/desktop/hyprland.nix
      /home/profiles/gui.nix
      /stylix
      /syncthing/workstation.nix
    ]
    ++ [
      agenix.homeManagerModules.default
      stylix.homeModules.stylix
    ];
}
