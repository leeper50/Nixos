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
        darwin
        home-manager
        nixpkgs
        nur
        ;
      inherit (nixpkgs) lib;

      globals = import ./globals.nix { inherit lib; };

      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          overlays = [ nur.overlays.default ];
          config.allowUnfree = true;
          config.permittedInsecurePackages = [
            "electron-39.8.10"
            "pnpm-10.29.2"
          ];
        };

      mkNixosSystem =
        { modules, profile }:
        lib.nixosSystem {
          pkgs = mkPkgs "x86_64-linux";
          specialArgs = inputs // {
            inherit globals profile;
            systemType = "Nixos";
            osConfig = null;
          };
          inherit modules;
        };

      mkHost =
        {
          deployment,
          modules,
          profile,
        }:
        {
          inherit profile;
          nixos = mkNixosSystem { inherit modules profile; };
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
              "servers"
              "swarm"
            ];
          };
          modules = [
            ./hosts/proxmox-lxc
            ./hosts/proxmox-lxc/${name}
          ];
          profile = "cli";
        };

      hosts = {
        komodo = mkHost {
          deployment = {
            targetHost = "komodo";
            tags = [
              "local"
              "servers"
            ];
          };
          modules = [
            ./hosts/proxmox-vm
            ./hosts/proxmox-vm/komodo
          ];
          profile = "cli";
        };

        laptop = mkHost {
          deployment = {
            targetHost = "laptop";
            tags = [ "local" ];
          };
          modules = [
            ./hosts/laptop
          ];
          profile = "gui";
        };

        nas = mkHost {
          deployment = {
            targetHost = "nas";
            tags = [
              "local"
              "servers"
            ];
          };
          modules = [
            ./hosts/proxmox-vm
            ./hosts/proxmox-vm/nas
          ];
          profile = "cli";
        };

        "node-1" = mkSwarmHost "node-1";
        "node-2" = mkSwarmHost "node-2";
        "node-3" = mkSwarmHost "node-3";

        racknerd = mkHost {
          deployment = {
            targetHost = "racknerd";
            tags = [
              "remote"
              "servers"
            ];
          };
          modules = [
            ./hosts/racknerd
          ];
          profile = "cli";
        };

        servercheap = mkHost {
          deployment = {
            targetHost = "servercheap";
            tags = [
              "remote"
              "servers"
            ];
          };
          modules = [
            ./hosts/servercheap
          ];
          profile = "cli";
        };
      };
    in
    {
      darwinConfigurations = {
        "macbook" = darwin.lib.darwinSystem {
          pkgs = mkPkgs "aarch64-darwin";
          specialArgs = inputs // {
            inherit inputs globals;
            systemType = "NixDarwin";
            osConfig = null;
          };
          modules = [
            ./hosts/macbook
          ];
        };
      };

      homeConfigurations = {
        "workstation" = home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs "x86_64-linux";
          extraSpecialArgs = inputs // {
            inherit globals;
            systemType = "Standalone";
            hostName = "workstation";
          };
          modules = [
            ./hosts/workstation
          ];
        };
      };

      nixosConfigurations = lib.mapAttrs (_: host: host.nixos) hosts;

      colmena = {
        meta = {
          nixpkgs = mkPkgs "x86_64-linux";
          specialArgs = inputs // {
            inherit globals;
            systemType = "Nixos";
            osConfig = null;
          };
          nodeSpecialArgs = lib.mapAttrs (_: host: { inherit (host) profile; }) hosts;
        };
      }
      // lib.mapAttrs (_: host: host.colmena) hosts;
    };
}
