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
    {
      nixosConfigurations = {
        server = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            agenix.nixosModules.default
            ./agenix.nix
            ./configuration.nix
            ./podman.nix
            ./samba.nix
            ./secrets/secrets.nix
            ./user-walter.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.walter = ./home.nix;
            }
          ];
        };
      };
    };
}
