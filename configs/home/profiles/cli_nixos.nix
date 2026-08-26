{
  agenix,
  globals,
  systemType,
  ...
}:
{
  imports = [
    {
      home-manager = {
        extraSpecialArgs = { inherit agenix globals systemType; };
        useGlobalPkgs = true;
        useUserPackages = true;
        users.${globals.username}.imports = [
          agenix.homeManagerModules.default
          ../../../secrets
          ../default.nix
        ];
      };
    }
  ];
}
