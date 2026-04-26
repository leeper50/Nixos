{
  description = "Home Manager configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    agenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs:
    let
      inherit (inputs)
        agenix
        darwin
        disko
        nur
        home-manager
        nixpkgs
        plasma-manager
        self
        stylix
        ;
      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          overlays = [
            nur.overlays.default
          ];
          config = {
            allowUnfree = true;
          };
        };
    in
    {
      darwinConfigurations = {
        "macbook" = darwin.lib.darwinSystem {
          pkgs = mkPkgs "aarch64-darwin";
          specialArgs = inputs;
          modules = [
            ./darwin
            ./darwin/homebrew
            home-manager.darwinModules.home-manager
            stylix.darwinModules.stylix
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = inputs;
              home-manager.sharedModules = [ stylix.homeModules.stylix ];
              home-manager.users.walter = {
                imports = [ ./home ];
              };
            }
          ];
        };
      };
      homeConfigurations = {
        "workstation" = home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs "x86_64-linux";
          extraSpecialArgs = inputs;
          modules = [
            ./home
            ./home/desktop/plasma.nix
            stylix.homeModules.stylix
          ];
        };
      };
      nixosConfigurations = {
        gk55 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs;
          modules = [
            ./hosts/gk55
            ./nixos
          ];
        };
        nas = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs;
          modules = [
            ./hosts/nas
            ./nixos
            ./nixos/services/nfs.nix
            ./nixos/services/samba.nix
            ./nixos/services/syncthing.nix
          ];
        };
        node-1 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs;
          modules = [
            disko.nixosModules.disko
            ./hosts/node-1
            ./nixos
            ./nixos/services/docker.nix
          ];
        };
        node-2 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs;
          modules = [
            disko.nixosModules.disko
            ./hosts/node-2
            ./nixos
            ./nixos/services/docker.nix
          ];
        };
        node-3 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs;
          modules = [
            disko.nixosModules.disko
            ./hosts/node-3
            ./nixos
            ./nixos/services/docker.nix
          ];
        };
      };
    };
}
