{ agenix, home-manager, ... }:
{
  imports = [
    agenix.nixosModules.default
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.walter = {
        imports = [
          ../home/base
          ../home/shell
        ];
      };
    }

    # Configs
    ./configs/agenix.nix
    ./configs/cleanup.nix
    ./configs/locales.nix
    ./configs/packages.nix
    ./configs/users.nix

    # Services
    ./services/ssh.nix
  ];
}
