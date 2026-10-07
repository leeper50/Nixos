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
          overlays = [ nur.overlays.default ];
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
        "k3s-01" = mkHost {
          deployment = {
            targetHost = "k3s-01";
            tags = [
              "local"
              "servers"
            ];
          };
          modules = [
            ./hosts/proxmox-vm
            ./hosts/proxmox-vm/k3s-01
          ];
          profile = "cli";
          proxmox = {
            vm_id = 1011;
            cores = 6;
            memory = 6144;
          };
        };

        "k3s-02" = mkHost {
          deployment = {
            targetHost = "k3s-02";
            tags = [
              "local"
              "servers"
            ];
          };
          modules = [
            ./hosts/proxmox-vm
            ./hosts/proxmox-vm/k3s-02
          ];
          profile = "cli";
          proxmox = {
            node_name = "tower";
            vm_id = 1012;
            cores = 6;
            memory = 6144;
            datastore_id = "nvme_tower";
          };
        };

        "k3s-03" = mkHost {
          deployment = {
            targetHost = "k3s-03";
            tags = [
              "local"
              "servers"
            ];
          };
          modules = [
            ./hosts/proxmox-vm
            ./hosts/proxmox-vm/k3s-03
          ];
          profile = "cli";
          proxmox = {
            node_name = "gk55";
            vm_id = 1013;
            cores = 4;
            memory = 4096;
            disk_size = 20;
            data_disk_size = 20;
          };
        };

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
