{ ... }:
{
  imports = [
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.walter.imports = [ ./cli.nix ];
      };
    }
  ];
}
