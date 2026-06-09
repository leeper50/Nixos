{ stylix, ... }:
{
  imports = [
    {
      home-manager = {
        sharedModules = [ stylix.homeModules.stylix ];
        useGlobalPkgs = true;
        useUserPackages = true;
        users.walter.imports = [ ./profiles/gui.nix ];
      };
    }
  ];
}
