{ agenix, home-manager, ... }:
{
  imports = [
    agenix.nixosModules.default
    home-manager.nixosModules.home-manager

    # Configs
    ../secrets
    ./configs/cleanup.nix
    ./configs/locales.nix
    ./configs/packages.nix
    ./configs/sudo.nix
    ./configs/users.nix

    # Services
    ./services/ssh.nix
  ];
}
