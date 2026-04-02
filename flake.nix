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
    firefox-addons = {
      url = "github:osipog/nix-firefox-addons";
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
        firefox-addons
        home-manager
        nixpkgs
        plasma-manager
        self
        stylix
        ;
      allowedUnfree = [
        "1password-x-password-manager"
        "1password"
        "claude-code"
        "firefox-bin-unwrapped"
        "firefox-bin"
        "google-chrome"
        "obsidian"
        "teamspeak6-client"
        "vivaldi"
        "vscode-extension-anthropic-claude-code"
        "wowup-cf"
      ];
      lib = nixpkgs.lib;
      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          overlays = [
            firefox-addons.overlays.default
          ];
          config = {
            allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) allowedUnfree;
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
        ser8 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs;
          modules = [
            ./hosts/ser8
            ./nixos
            ./nixos/services/samba.nix
            ./nixos/services/syncthing.nix
          ];
        };
      };
    };
}
