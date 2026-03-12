{
  description = "Home Manager configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    agenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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
          home-manager.users.walter = ./common/home.nix;
        }
        ./common/agenix.nix
        ./common/power.nix
      ];
    in
    {
      nixosConfigurations = {
        gk55 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = commonModules ++ [
            ./modules/avahi.nix
            ./modules/ssh.nix
            ./system/gk55/configuration.nix
          ];
        };
        ser8 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = commonModules ++ [
            ./modules/avahi.nix
            ./modules/samba.nix
            ./modules/ssh.nix
            ./system/ser8/configuration.nix
          ];
        };
      };
    };
}
