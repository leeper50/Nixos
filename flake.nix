{
  description = "Home Manager configuration";
  inputs = {
    agenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    colmena = {
      url = "github:zhaofengli/colmena";
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
        colmena
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
          overlays = [ nur.overlays.default ];
          config.allowUnfree = true;
        };

      mkNixosSystem =
        modules:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs;
          inherit modules;
        };

      mkHost =
        { deployment, modules }:
        {
          nixos = mkNixosSystem modules;
          colmena = {
            inherit deployment;
            imports = modules;
          };
        };

      mkSwarmHost =
        name:
        mkHost {
          deployment = {
            targetHost = name;
            tags = [
              "local"
              "swarm"
            ];
          };
          modules = [
            ./home/cli.nix
            ./hosts/proxmox-lxc
            ./hosts/proxmox-lxc/${name}
            ./nixos
            ./nixos/configs/local_networking.nix
            ./nixos/services/avahi.nix
            ./nixos/services/docker
            ./nixos/services/docker/komodo.nix
            ./nixos/services/docker/swarm.nix
            ./nixos/services/keepalived.nix
            ./nixos/services/power.nix
          ];
        };

      hosts = {
        gk55 = mkHost {
          deployment = {
            targetHost = "gk55";
            tags = [ "" ]; # Machine not currently using nixos
          };
          modules = [
            ./home/cli.nix
            ./hosts/gk55
            ./nixos
            ./nixos/configs/local_networking.nix
            ./nixos/services/avahi.nix
          ];
        };

        laptop = mkHost {
          deployment = {
            targetHost = "laptop";
            tags = [ "local" ];
          };
          modules = [
            ./home/gui.nix
            ./hosts/laptop
            ./nixos
            ./nixos/desktop
            ./nixos/configs/local_networking.nix
            ./nixos/services/avahi.nix
          ];
        };

        nas = mkHost {
          deployment = {
            targetHost = "nas";
            tags = [
              "local"
            ];
          };
          modules = [
            ./home/cli.nix
            ./hosts/proxmox-vm
            ./hosts/proxmox-vm/nas
            ./nixos
            ./nixos/configs/local_networking.nix
            ./nixos/services/avahi.nix
            ./nixos/services/nfs.nix
            ./nixos/services/samba.nix
            ./nixos/services/syncthing.nix
            disko.nixosModules.disko
          ];
        };

        racknerd = mkHost {
          deployment = {
            targetHost = "racknerd";
            tags = [ "remote" ];
          };
          modules = [
            ./home/cli.nix
            ./hosts/racknerd
            ./nixos
            ./nixos/services/murmur.nix
          ];
        };

        servercheap = mkHost {
          deployment = {
            targetHost = "servercheap";
            tags = [ "remote" ];
          };
          modules = [
            ./home/cli.nix
            ./hosts/servercheap
            ./nixos
          ];
        };

        "node-1" = mkSwarmHost "node-1";
        "node-2" = mkSwarmHost "node-2";
        "node-3" = mkSwarmHost "node-3";
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
            agenix.homeManagerModules.default
            home-manager.darwinModules.home-manager
            stylix.darwinModules.stylix
            {
              home-manager.extraSpecialArgs = inputs;
              home-manager.sharedModules = [ stylix.homeModules.stylix ];
              home-manager.users.walter.imports = [ ./home/profiles/gui.nix ];
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
            ./home/profiles/gui.nix
            ./home/desktop/hyprland.nix
            agenix.homeManagerModules.default
            stylix.homeModules.stylix
          ];
        };
      };

      nixosConfigurations = {
        # gk55 = hosts.gk55.nixos; # gk55 currently running proxmox
        laptop = hosts.laptop.nixos;
        nas = hosts.nas.nixos;
        racknerd = hosts.racknerd.nixos;
        servercheap = hosts.servercheap.nixos;
        "node-1" = hosts."node-1".nixos;
        "node-2" = hosts."node-2".nixos;
        "node-3" = hosts."node-3".nixos;
      };

      colmena = {
        meta = {
          nixpkgs = mkPkgs "x86_64-linux";
          specialArgs = inputs;
        };
        # gk55 = hosts.gk55.colmena; # gk55 currently running proxmox
        laptop = hosts.laptop.colmena;
        nas = hosts.nas.colmena;
        racknerd = hosts.racknerd.colmena;
        servercheap = hosts.servercheap.colmena;
        "node-1" = hosts."node-1".colmena;
        "node-2" = hosts."node-2".colmena;
        "node-3" = hosts."node-3".colmena;
      };
    };
}
