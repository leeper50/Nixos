{
  agenix,
  globals,
  pkgs,
  self,
  ...
}:
{
  imports = [
    agenix.darwinModules.default
    ../../secrets
  ];
  nixpkgs.overlays = [
    (final: prev: {
      inherit (prev.lixPackageSets.stable)
        colmena
        nix-eval-jobs
        nix-fast-build
        nixpkgs-review
        ;
    })
  ];
  environment.shells = [
    pkgs.fish
  ];
  homebrew = {
    brews = [ ];
    casks = [
      "elegoo-slicer"
      "freac"
      "keepassxc"
      "onlyoffice"
      "parsec"
      "qview"
    ];
    enable = true;
    enableFishIntegration = true;
  };
  home-manager.backupFileExtension = "home_manager_backup";
  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
    package = pkgs.lixPackageSets.stable.lix;
    settings = {
      auto-optimise-store = true;
      experimental-features = "nix-command flakes";
    };
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
          app = "/Users/${globals.username}/Applications/Home Manager Apps/Firefox.app";
        }
        {
          app = "/Users/${globals.username}/Applications/Home Manager Apps/kitty.app";
        }
        {
          app = "/Users/${globals.username}/Applications/Home Manager Apps/Visual Studio Code.app";
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
  system.primaryUser = globals.username;
  system.stateVersion = 6;
  time.timeZone = globals.timeZone;
  users.users.${globals.username} = {
    home = "/Users/${globals.username}";
    shell = pkgs.fish;
  };
}
