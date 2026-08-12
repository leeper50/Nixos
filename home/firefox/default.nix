{ pkgs, lib, ... }:
let
  firefoxPackage = pkgs.firefox-bin;
in
{
  imports = [ ./extensions.nix ];
  stylix.targets.firefox = {
    colorTheme.enable = true;
    profileNames = [ "default" ];
  };
  programs.firefox = {
    enable = true;
    configPath =
      if pkgs.stdenv.isLinux then ".mozilla/firefox" else "Library/Application Support/Firefox";
    package = firefoxPackage;
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
          "network.proxy.no_proxies_on" = "localhost,dellhplaptop.xyz,buncha.men,10.0.0.0/8";
          "network.proxy.type" = 0;
        };
      };
    };
    policies = import ./policies.nix;
  };
}
