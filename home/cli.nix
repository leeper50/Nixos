{ ... }:
{
  imports = [
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.walter.imports = [ ./profiles/cli.nix ];
      };
    }
  ];
}
