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
        ]
        ++ map (p: rootDir + p) [
          /home/profiles/gui.nix
          /secrets
        ]
        ++ [
          ./home.nix
        ];
        home-manager.useUserPackages = true;
      }
    ];
}
