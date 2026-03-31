{
  pkgs,
  ...
}:
let
  firefoxPackage = pkgs.firefox-bin;
in
{
  stylix.targets.firefox.profileNames = [ "default" ];
  programs.firefox = {
    enable = true;
    package = firefoxPackage;
    languagePacks = [ "en-US" ];
    profiles = {
      default = {
        isDefault = true;
        extensions = {
          force = true;
          packages = [
            pkgs.firefoxAddons."1password-x-password-manager"
            pkgs.firefoxAddons.decentraleyes
            pkgs.firefoxAddons.indie-wiki-buddy
            pkgs.firefoxAddons.istilldontcareaboutcookies
            pkgs.firefoxAddons.mute-sites-by-default
            pkgs.firefoxAddons.reddit-enhancement-suite
            pkgs.firefoxAddons.redirect-to-wiki-gg
            pkgs.firefoxAddons.surge
            pkgs.firefoxAddons.ublock-origin
            pkgs.firefoxAddons.violentmonkey
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
          "browser.startup.homepage" = "https://www.dellhplaptop.xyz";
          "extensions.autoDisableScopes" = 0;
          "extensions.update.autoUpdateDefault" = false;
          "extensions.update.enable" = false;
          "general.autoScroll" = true;
        };
      };
    };
    policies = {
      # Updates & Background Services
      AppAutoUpdate = false;
      BackgroundAppUpdate = false;

      # Feature Disabling
      DisableBuiltinPDFViewer = true;
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
      PasswordManagerEnabled = true;

      # Access Restrictions
      BlockAboutConfig = false;
      BlockAboutProfiles = false;
      BlockAboutSupport = false;

      # Privacy & Security
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
      HttpsOnlyMode = "force_enabled";
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
