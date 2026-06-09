{ agenix, home-manager, ... }:
{
  imports = [
    agenix.nixosModules.default
    home-manager.nixosModules.home-manager

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
