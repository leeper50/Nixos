{
  config,
  lib,
  pkgs,
  ...
}:
let
  firefoxPackage = if pkgs.stdenv.isLinux then pkgs.librewolf else pkgs.firefox-bin;
in
{
  stylix.targets.firefox.profileNames = [ "default" ];
  programs.firefox = {
    enable = true;
    configPath = if pkgs.stdenv.isLinux then ".config/librewolf/librewolf" else ".mozilla/firefox";
    package = firefoxPackage;
    languagePacks = [ "en-US" ];
    profiles = {
      default = {
        isDefault = true;
        extensions = {
          force = true;
          packages = with pkgs.nur.repos.rycee.firefox-addons; [
            bitwarden
            decentraleyes
            foxyproxy-standard
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
