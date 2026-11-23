{
  agenix,
  globals,
  home-manager,
  inputs,
  lib,
  pkgs,
  profile,
  secrets,
  stylix,
  ...
}:
{
  imports = [
    ../../configs/darwin
    ../../configs/home/gui/stylix.nix
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
        users.walter.imports = [
          (import ./home.nix {
            inherit
              agenix
              lib
              pkgs
              profile
              secrets
              ;
          })
        ];
        useUserPackages = true;
      };
    }
  ];
}
