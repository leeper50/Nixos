{
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
  HttpsOnlyMode = "allowed";
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
}
