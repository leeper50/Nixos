{
  globals,
  home-manager,
  inputs,
  stylix,
  ...
}:
{
  imports = [
    ../../configs/darwin
    ../../configs/home/stylix.nix
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
          ./home.nix
        ];
        useUserPackages = true;
      };
    }
  ];
}
