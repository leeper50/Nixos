{
  agenix,
  stylix,
  ...
}:
let
  rootDir = ../..;
in
{
  imports =
    map (p: rootDir + p) [
      /home/profiles/gui_linux.nix
      /secrets
      /stylix
      /syncthing/workstation.nix
    ]
    ++ [
      agenix.homeManagerModules.default
      stylix.homeModules.stylix
    ];
}
