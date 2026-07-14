{
  agenix,
  pkgs,
  self,
  ...
}:
{
  imports = [
    agenix.darwinModules.default
    ../secrets
  ];

  nixpkgs.overlays = [
    (final: prev: {
      inherit (prev.lixPackageSets.stable)
        nixpkgs-review
        nix-eval-jobs
        nix-fast-build
        colmena
        ;
    })
  ];

  environment.shells = [
    pkgs.fish
  ];

  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
    settings = {
      auto-optimise-store = true;
      experimental-features = "nix-command flakes";
    };
    package = pkgs.lixPackageSets.stable.lix;
  };
  nixpkgs.hostPlatform = "aarch64-darwin";

  programs.fish.enable = true;
  services.tailscale.enable = true;

  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.defaults = {
    dock = {
      autohide = true;
      minimize-to-application = true;
      persistent-apps = [
        {
          app = "/Users/walter/Applications/Home Manager Apps/Firefox.app";
        }
        {
          app = "/Users/walter/Applications/Home Manager Apps/kitty.app";
        }
        {
          app = "/Users/walter/Applications/Home Manager Apps/Visual Studio Code.app";
        }
        {
          app = "/System/Applications/System Settings.app";
        }
      ];
      show-recents = false;
      tilesize = 64;
      wvous-bl-corner = 1;
      wvous-br-corner = 1;
      wvous-tl-corner = 1;
      wvous-tr-corner = 1;
    };
    finder = {
      _FXShowPosixPathInTitle = true;
      _FXSortFoldersFirst = true;
      AppleShowAllExtensions = true;
      FXDefaultSearchScope = "SCcf";
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "clmv";
      FXRemoveOldTrashItems = true;
      ShowPathbar = true;
    };
    NSGlobalDomain = {
      "com.apple.swipescrolldirection" = false;
    };
    trackpad = {
      Clicking = true;
    };
  };
  system.primaryUser = "walter";
  system.stateVersion = 6;

  users.users.walter = {
    home = "/Users/walter";
    shell = pkgs.fish;
  };
}
