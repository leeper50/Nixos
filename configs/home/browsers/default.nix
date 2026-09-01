{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.local.browsers;
  chromiumPackage = pkgs.brave;
  firefoxPackage = pkgs.firefox-bin;
  floorpPackage = pkgs.floorp-bin;
  librewolfPackage = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.librewolf else pkgs.librewolf-bin;
  commonFirefoxSettings = {
    enable = true;
    languagePacks = [ "en-US" ];
    profiles = {
      default = {
        isDefault = true;
        name = "default";
        bookmarks = {
          force = true;
          settings = import ./bookmarks.nix;
        };
        search = import ./search.nix;
        containersForce = true;
        containers = lib.mapAttrs (_: c: { inherit (c) id color icon; }) (import ./containers.nix);
        settings = {
          "browser.aboutConfig.showWarning" = false;
          "browser.download.viewableInternally.typeWasRegistered.jxl" = true;
          "browser.fixup.domainsuffixwhitelist.i2p" = true;
          "browser.startup.homepage" = "https://www.dellhplaptop.xyz";
          "browser.urlbar.trimURLs" = false;
          "extensions.autoDisableScopes" = 0;
          "extensions.update.autoUpdateDefault" = false;
          "extensions.update.enable" = false;
          "general.autoScroll" = true;
          "image.jxl.enabled" = true;
          "network.proxy.autoconfig_url" = "https://c.dellhplaptop.xyz/public/proxy.pac";
          "network.proxy.no_proxies_on" = "localhost,dellhp.party,dellhplaptop.xyz,buncha.men,10.0.0.0/8";
        };
      };
    };
    policies = import ./policies.nix;
  };
in
{
  options.local.browsers = {
    brave.enable = lib.mkEnableOption "brave";
    firefox.enable = lib.mkEnableOption "firefox";
    floorp.enable = lib.mkEnableOption "floorp";
    librewolf.enable = lib.mkEnableOption "librewolf";
  };
  imports = [ ./extensions.nix ];
  config = lib.mkMerge [
    (lib.mkIf cfg.brave.enable {
      programs.chromium = {
        commandLineArgs = [
          "--proxy-pac-url=https://c.dellhplaptop.xyz/public/proxy.pac"
        ];
        enable = true;
        package = chromiumPackage;
      };
    })
    (lib.mkIf cfg.firefox.enable {
      stylix.targets = {
        firefox = {
          colorTheme.enable = true;
          profileNames = [ "default" ];
        };
      };
      programs.firefox = lib.recursiveUpdate commonFirefoxSettings {
        package = firefoxPackage;
        profiles.default.settings."network.proxy.type" = 0;
      };
    })
    (lib.mkIf cfg.floorp.enable {
      stylix.targets = {
        floorp = {
          colorTheme.enable = true;
          profileNames = [ "default" ];
        };
      };
      programs.floorp = lib.recursiveUpdate commonFirefoxSettings {
        package = floorpPackage;
        profiles.default.settings."network.proxy.type" = 0;
      };
    })
    (lib.mkIf cfg.librewolf.enable {
      stylix.targets = {
        librewolf = {
          colorTheme.enable = true;
          profileNames = [ "default" ];
        };
      };
      programs.librewolf = lib.recursiveUpdate commonFirefoxSettings {
        package = librewolfPackage;
        profiles.default.settings."network.proxy.type" = 2;
      };
    })
  ];
}
