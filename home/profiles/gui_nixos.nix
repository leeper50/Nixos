{ stylix, ... }:
{
  imports = [
    stylix.nixosModules.stylix
    ../../stylix
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.walter.imports = [ ./gui_linux.nix ];
      };
    }
  ];
}
