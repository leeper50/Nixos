{ pkgs, ... }:
let
  firefoxPackage = pkgs.firefox-bin; # if pkgs.stdenv.isLinux then pkgs.librewolf else pkgs.firefox-bin;
in
{
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
        bookmarks = {
          force = true;
          settings = import ./bookmarks.nix;
        };
        isDefault = true;
        extensions = {
          force = true;
          packages = with pkgs.nur.repos.rycee.firefox-addons; [
            bitwarden
            decentraleyes
            indie-wiki-buddy
            istilldontcareaboutcookies
            new-tab-override
            reddit-enhancement-suite
            redirect-to-wiki-gg
            ublock-origin
            violentmonkey
          ];
          settings = {
            "uBlock0@raymondhill.net".settings = {
              selectedFilterLists = [
                "easylist"
                "easyprivacy"
                "plowe-0"
                "ublock-badware"
                "ublock-filters"
                "ublock-privacy"
                "ublock-quick-fixes"
                "ublock-unbreak"
                "urlhaus-1"
              ];
            };
            "newtaboverride@agenedia.com".settings = {
              type = "homepage";
              focus_website = true;
            };
          };
        };
        name = "default";
        search = {
          default = "ddg_noai";
          engines = {
            ddg_noai = {
              name = "Duckduckgo No AI";
              urls = [ { template = "https://noai.duckduckgo.com/?q={searchTerms}"; } ];
              iconMapObj."16" = "https://noai.duckduckgo.com/favicon.ico";
              definedAliases = [ "@dd" ];
            };
          };
          force = true;
        };
        settings = {
          "browser.aboutConfig.showWarning" = false;
          "browser.download.viewableInternally.typeWasRegistered.jxl" = true;
          "browser.startup.homepage" = "https://www.dellhplaptop.xyz";
          "browser.urlbar.trimURLs" = false;
          "extensions.autoDisableScopes" = 0;
          "extensions.update.autoUpdateDefault" = false;
          "extensions.update.enable" = false;
          "general.autoScroll" = true;
          "image.jxl.enabled" = true;
          "network.proxy.autoconfig_url" = "https://c.dellhplaptop.xyz/public/proxy.pac";
          "network.proxy.no_proxies_on" = "localhost,dellhplaptop.xyz,buncha.men,10.0.0.0/8";
          "network.proxy.type" = 2;
        };
      };
    };
    policies = {
      # Updates & Background Services
      AppAutoUpdate = false;
      BackgroundAppUpdate = false;

      # Feature Disabling
      DisableBuiltinPDFViewer = false;
      DisableFirefoxAccounts = true;
      DisableFirefoxScreenshots = true;
      DisableFirefoxStudies = true;
      DisableForgetButton = true;
      DisableFormHistory = true;
      DisableMasterPasswordCreation = true;
      DisablePasswordReveal = true;
      DisablePocket = true;
      DisableProfileImport = true;
      DisableProfileRefresh = true;
      DisableSetDesktopBackground = true;
      DisableTelemetry = true;
      PasswordManagerEnabled = false;

      # Access Restrictions
      BlockAboutConfig = false;
      BlockAboutProfiles = false;
      BlockAboutSupport = false;

      # Privacy & Security
      AIControls = {
        Default = {
          Locked = true;
          Value = "blocked";
        };
      };
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      EnableTrackingProtection = {
        BaselineExceptions = true;
        Category = "strict";
        ConvenienceExceptions = true;
        Locked = true;
      };
      FirefoxSuggest = {
        ImproveSuggest = false;
        Locked = true;
        SponsoredSuggestions = false;
        WebSuggestions = false;
      };
      GenerativeAI = {
        Enabled = false;
        Locked = true;
      };
      HttpsOnlyMode = "enabled";
      Permissions = {
        Autoplay = {
          BlockNewRequests = true;
          Locked = true;
        };
        Location = {
          BlockNewRequests = true;
          Locked = true;
        };
        Notifications = {
          BlockNewRequests = true;
          Locked = true;
        };
        VirtualReality = {
          BlockNewRequests = true;
          Locked = true;
        };
      };
      PostQuantumKeyAgreementEnabled = true;
      SanitizeOnShutdown = {
        Cache = true;
        FormData = true;
        History = true;
        Locked = true;
        Sessions = true;
      };

      # UI and Behavior
      DisplayMenuBar = "never";
      DontCheckDefaultBrowser = true;
      HardwareAcceleration = true;
      OfferToSaveLogins = false;
      PictureInPicture = false;
    };
  };
}
