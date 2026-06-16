{ agenix, systemType, ... }:
{
  imports = [
    {
      home-manager = {
        extraSpecialArgs = { inherit agenix systemType; };
        useGlobalPkgs = true;
        useUserPackages = true;
        users.walter.imports = [
          agenix.homeManagerModules.default
          ../../secrets/agenix.nix
          ./cli.nix
        ];
      };
    }
  ];
}
