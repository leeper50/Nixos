{
  description = "Home Manager configuration";
  inputs = {
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
    home-manager = {
      url = "github:nix-community/home-manager/";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nur = {
      url = "github:nix-community/NUR";
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
        home-manager
        nixpkgs
        nur
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
              home-manager.extraSpecialArgs = inputs;
              home-manager.sharedModules = [ stylix.homeModules.stylix ];
              home-manager.users.walter = {
                imports = [ ./home ];
              };
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
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
            ./home/desktop/hyprland.nix
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

            # Global settings
            ./nixos

            # Specific settings
            ./nixos/configs/local_networking.nix

            # Services
            ./nixos/services/avahi.nix
          ];
        };
        nas = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs;
          modules = [
            ./hosts/proxmox-vm
            ./hosts/proxmox-vm/nas

            # Global settings
            ./nixos

            # Specific settings
            ./nixos/configs/local_networking.nix

            # Services
            ./nixos/services/avahi.nix
            ./nixos/services/nfs.nix
            ./nixos/services/samba.nix
            ./nixos/services/syncthing.nix
            disko.nixosModules.disko
          ];
        };
        racknerd = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs;
          modules = [
            ./hosts/racknerd

            # Global settings
            ./nixos

            # Services
            ./nixos/services/murmur.nix
          ];
        };
        servercheap = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs;
          modules = [
            ./hosts/servercheap

            # Global settings
            ./nixos
          ];
        };
      }
      // nixpkgs.lib.genAttrs [ "node-1" "node-2" "node-3" ] (
        name:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs;
          modules = [
            ./hosts/proxmox-lxc
            ./hosts/proxmox-lxc/${name}

            # Global settings
            ./nixos

            # Specific settings
            ./nixos/configs/local_networking.nix

            # Services
            ./nixos/services/avahi.nix
            ./nixos/services/docker
            ./nixos/services/docker/komodo.nix
            ./nixos/services/docker/swarm.nix
            ./nixos/services/keepalived.nix
            ./nixos/services/power.nix
          ];
        }
      );
    };
}
