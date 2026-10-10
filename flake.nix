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
    comin = {
      url = "github:nlewo/comin";
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
    # TEMPORARY: authelia from the revision before pnpm 12.9 broke its pnpmDepsHash
    # (https://github.com/NixOS/nixpkgs/issues/571789). Same 4.39.27 build servercheap
    # already ran; its DB is at schema 29, so don't pin anything older than that.
    # Remove together with the overlay in mkPkgs once nixpkgs is fixed.
    nixpkgs-authelia.url = "github:nixos/nixpkgs/7a0f122f5090cf4c2ade2a13a0e229d4e19ba71f";
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

      mkGlobals = hostName: import ./globals.nix { inherit lib hostName; };

      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          overlays = [
            nur.overlays.default
            # TEMPORARY, see the nixpkgs-authelia input.
            (_: prev: {
              inherit (inputs.nixpkgs-authelia.legacyPackages.${prev.stdenv.hostPlatform.system}) authelia;
            })
          ];
          config.allowUnfree = true;
        };

      mkNixosSystem =
        {
          modules,
          name,
          profile,
        }:
        lib.nixosSystem {
          pkgs = mkPkgs "x86_64-linux";
          specialArgs = inputs // {
            inherit profile;
            globals = mkGlobals name;
            systemType = "Nixos";
            osConfig = null;
          };
          inherit modules;
        };

      # `proxmox` is the VM's shape for OpenTofu (see OpenTofu/main.tf for the
      # defaults it is merged with). Only hosts that set it are created by Tofu.
      mkHost =
        {
          deployment,
          modules,
          profile,
          proxmox ? null,
        }:
        {
          inherit deployment modules profile;
        }
        // lib.optionalAttrs (proxmox != null) { inherit proxmox; };

      mkSwarmHost =
        name: proxmox:
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
            ./hosts/proxmox-vm
            ./hosts/proxmox-vm/swarm.nix
            ./hosts/proxmox-vm/${name}
          ];
          profile = "cli";
          inherit proxmox;
        };

      hosts = {
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
          proxmox = {
            node_name = "tower";
            vm_id = 1004;
            cores = 4;
            memory = 6144;
            datastore_id = "nvme_tower";
            disk_size = 64;
            data_disk_size = 0;
            pci_mappings = [ "tower-sata" ];
          };
        };

        "node-1" = mkSwarmHost "node-1" {
          node_name = "ser8";
          vm_id = 1001;
          cores = 12;
          memory = 16384;
          disk_size = 32;
          data_disk_size = 64;
          usb_mappings = [
            "zigbee"
            "zwave"
          ];
        };
        "node-2" = mkSwarmHost "node-2" {
          node_name = "tower";
          vm_id = 1002;
          cores = 8;
          memory = 8192;
          datastore_id = "nvme_tower";
          disk_size = 64;
          data_disk_size = 64;
          pci_mappings = [ "tower-igpu" ];
        };
        "node-3" = mkSwarmHost "node-3" {
          node_name = "gk55";
          vm_id = 1003;
          cores = 4;
          memory = 4096;
          disk_size = 32;
          data_disk_size = 32;
        };

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
            inherit inputs;
            globals = mkGlobals "macbook";
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
            globals = mkGlobals "workstation";
            systemType = "Standalone";
            hostName = "workstation";
          };
          modules = [
            ./hosts/workstation
          ];
        };
      };

      nixosConfigurations = lib.mapAttrs (
        name: host:
        mkNixosSystem {
          inherit name;
          inherit (host) modules profile;
        }
      ) hosts;

      colmena = {
        meta = {
          nixpkgs = mkPkgs "x86_64-linux";
          specialArgs = inputs // {
            systemType = "Nixos";
            osConfig = null;
          };
          nodeSpecialArgs = lib.mapAttrs (name: host: {
            inherit (host) profile;
            globals = mkGlobals name;
          }) hosts;
        };
      }
      // lib.mapAttrs (_: host: {
        inherit (host) deployment;
        imports = host.modules;
      }) hosts;

      colmenaHive = inputs.colmena.lib.makeHive inputs.self.colmena;

      # Consumed by OpenTofu as OpenTofu/vms.json; regenerated by tofu.fish.
      proxmoxVms = lib.mapAttrs (_: host: host.proxmox) (lib.filterAttrs (_: host: host ? proxmox) hosts);
    };
}
