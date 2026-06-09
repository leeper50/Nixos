{
  agenix,
  home-manager,
  stylix,
  ...
}:
let
  rootDir = ../..;
in
{
  imports =
    map (p: rootDir + p) [
      /darwin
      /darwin/homebrew
      /stylix
    ]
    ++ [
      agenix.homeManagerModules.default
      home-manager.darwinModules.home-manager
      stylix.darwinModules.stylix
      {
        home-manager.extraSpecialArgs = inputs;
        home-manager.useGlobalPkgs = true;
        home-manager.users.walter.imports = [ ../..home/profiles/gui.nix ];
        home-manager.useUserPackages = true;
      }
    ];
}
