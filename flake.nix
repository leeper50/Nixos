{
  description = "Home Manager configuration";
  inputs = {
    agenix = {
      url = "github:yaxitech/ragenix";
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
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
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
    # Agenix secrets, keys.nix and secrets.nix live in a private repo. Every
    # host fetches it over SSH with its host key (see configs/nixos/ssh.nix).
    secrets = {
      url = "git+ssh://git@fj.dellhplaptop.xyz:2222/wleeper13/nix-private.git";
      flake = false;
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

      # Systems that get a dev shell, formatter and checks.
      forAllSystems = lib.genAttrs [
        "aarch64-darwin"
        "x86_64-linux"
      ];

      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          overlays = [
            nur.overlays.default
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
          modules,
          profile,
          proxmox ? null,
        }:
        {
          inherit modules profile;
        }
        // lib.optionalAttrs (proxmox != null) { inherit proxmox; };

      mkSwarmHost =
        name: proxmox:
        mkHost {
          modules = [
            ./hosts/proxmox-vm
            ./hosts/proxmox-vm/swarm.nix
            ./hosts/proxmox-vm/${name}
          ];
          profile = "cli";
          inherit proxmox;
        };

      hosts = {
        action-runner = mkHost {
          modules = [
            ./hosts/proxmox-vm
            ./hosts/proxmox-vm/action-runner
          ];
          profile = "cli";
          proxmox = {
            node_name = "tower";
            vm_id = 1005;
            cores = 6;
            memory = 6144;
            datastore_id = "nvme_tower";
            disk_size = 64;
            data_disk_size = 0;
          };
        };

        laptop = mkHost {
          modules = [
            ./hosts/laptop
          ];
          profile = "gui";
        };

        nas = mkHost {
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
            data_disk_size = 200;
            pci_mappings = [ "tower-sata" ];
          };
        };

        "node-1" = mkSwarmHost "node-1" {
          node_name = "ser8";
          vm_id = 1001;
          cores = 12;
          memory = 16384;
          disk_size = 64;
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
          modules = [
            ./hosts/racknerd
          ];
          profile = "cli";
        };

        servercheap = mkHost {
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
        "walter@workstation" = home-manager.lib.homeManagerConfiguration {
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

      # Consumed by OpenTofu as OpenTofu/vms.json; regenerated by `just tofu`.
      proxmoxVms = lib.mapAttrs (_: host: host.proxmox) (lib.filterAttrs (_: host: host ? proxmox) hosts);

      # Run by the pre-commit hook and by CI.
      checks = forAllSystems (system: {
        pre-commit = inputs.git-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            deadnix.enable = true;
            nixfmt.enable = true;
            typos = {
              enable = true;
              settings.configPath = "_typos.toml";
            };
          };
        };
      });

      devShells = forAllSystems (
        system:
        let
          pkgs = mkPkgs system;
        in
        {
          default = pkgs.mkShell {
            # Installs the git pre-commit hook on entering the shell.
            inherit (inputs.self.checks.${system}.pre-commit) shellHook;
            packages =
              inputs.self.checks.${system}.pre-commit.enabledPackages
              ++ [
                pkgs.attic-client
                pkgs.fish
                pkgs.jq
                pkgs.just
                pkgs.nh
                pkgs.openssh
                pkgs.opentofu
                pkgs.ragenix
              ]
              # Manual deploys: nixos-rebuild switch --target-host <host>
              ++ lib.optional pkgs.stdenv.hostPlatform.isLinux pkgs.nixos-rebuild-ng;
          };
        }
      );

      formatter = forAllSystems (system: (mkPkgs system).nixfmt-tree);
    };
}
