{
  description = "Home Manager configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    agenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      agenix,
      home-manager,
      nixpkgs,
      ...
    }:
    let
      commonModules = [
        agenix.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.walter = home-manager/home.nix;
        }
        {
        }
        ./nixos/common/agenix.nix
        ./nixos/common/base_networking.nix
        ./nixos/common/cleanup.nix
        ./nixos/common/locales.nix
        ./nixos/common/packages.nix
        ./nixos/common/power.nix
        ./nixos/common/users.nix
      ];
    in
    {
      nixosConfigurations = {
        gk55 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = commonModules ++ [
            ./nixos/services/avahi.nix
            ./nixos/services/cockpit.nix
            ./nixos/services/ssh.nix
            ./system/gk55/configuration.nix
          ];
        };
        ser8 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = commonModules ++ [
            ./nixos/services/avahi.nix
            ./nixos/services/cockpit.nix
            # ./nixos/services/netbird.nix
            ./nixos/services/samba.nix
            ./nixos/services/ssh.nix
            ./nixos/services/syncthing.nix
            ./system/ser8/configuration.nix
          ];
        };
      };
    };
}
