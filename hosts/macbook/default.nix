{
  agenix,
  home-manager,
  inputs,
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
      home-manager.darwinModules.home-manager
      stylix.darwinModules.stylix
      {
        home-manager.extraSpecialArgs = inputs // {
          systemType = "NixDarwin";
        };
        home-manager.useGlobalPkgs = true;
        home-manager.users.walter.imports = [
          agenix.homeManagerModules.default
          ../../secrets/agenix.nix
          ../../home/profiles/gui.nix
          ../../syncthing/macbook.nix
        ];
        home-manager.useUserPackages = true;
      }
    ];
}
