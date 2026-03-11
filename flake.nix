{
  description = "Home Manager configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    agenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/latest";
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
      disko,
      home-manager,
      nixpkgs,
      ...
    }:
    {
      nixosConfigurations = {
        gk55 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            agenix.nixosModules.default
            disko.nixosModules.disko
            ./modules/agenix.nix
            ./modules/power.nix
            ./modules/samba.nix
            ./system/gk55/configuration.nix
            ./system/gk55/disko.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.walter = ./modules/home.nix;
            }
          ];
        };
      };
    };
}
