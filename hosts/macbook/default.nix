{
  globals,
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
      /hosts/darwin
      /stylix
    ]
    ++ [
      home-manager.darwinModules.home-manager
      stylix.darwinModules.stylix
      {
        home-manager = {
          extraSpecialArgs = inputs // {
            inherit globals;
            systemType = "NixDarwin";
          };
          useGlobalPkgs = true;
          users.${globals.username}.imports = [
            ./home.nix
          ];
          useUserPackages = true;
        };
      }
    ];
}
