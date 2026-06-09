{ agenix, stylix, ... }:
let
  rootDir = ../../..;
in
{
  imports =
    map (p: rootDir + p) [
      /home/desktop/hyprland.nix
      /home/profiles/gui.nix
      /stylix
    ]
    ++ [
      agenix.homeManagerModules.default
      stylix.homeModules.stylix
    ];
}
