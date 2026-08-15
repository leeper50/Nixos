{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.local.browsers;

  containers = import ./containers.nix;
  cookieStoreId = name: "firefox-container-${toString containers.${name}.id}";
  defaultContainer = lib.findFirst (name: containers.${name}.default or false) null (
    lib.attrNames containers
  );
  defaultRules = lib.optionalAttrs (defaultContainer != null) {
    "pref=defaultContainer" = {
      key = "defaultContainer";
      value = true;
    };
    "pref=defaultContainer.containerName" = {
      key = "defaultContainer.containerName";
      value = defaultContainer;
    };
    "pref=defaultContainer.lifetime" = {
      key = "defaultContainer.lifetime";
      value = "forever";
    };
    "pref=defaultContainer.ruleAddition" = {
      key = "defaultContainer.ruleAddition";
      value = "";
    };
  };
  siteRules = lib.listToAttrs (
    lib.flatten (
      lib.mapAttrsToList (
        name: container:
        map (site: {
          name = "map=${site}";
          value = {
            host = "!*.${site}";
            containerName = name;
            cookieStoreId = cookieStoreId name;
            enabled = true;
          };
        }) (container.sites or [ ])
      ) containers
    )
  );
  profileExtensions = {
    force = true;
    packages = with pkgs.nur.repos.rycee.firefox-addons; [
      bypass-paywalls-clean
      containerise
      decentraleyes
      indie-wiki-buddy
      istilldontcareaboutcookies
      keepassxc-browser
      new-tab-override
      reddit-enhancement-suite
      redirect-to-wiki-gg
      ublock-origin
      violentmonkey
    ];
    settings."containerise@kinte.sh" = {
      force = true;
      settings = siteRules // defaultRules;
    };
  };
  policyExtensions = {
    "uBlock0@raymondhill.net".toOverwrite = {
      filterLists = [
        "easylist"
        "easyprivacy"
        "plowe-0"
        "ublock-badware"
        "ublock-filters"
        "ublock-privacy"
        "ublock-quick-fixes"
        "ublock-unbreak"
        "urlhaus-1"
        "user-filters"
      ];
      filters = [
        "www.youtube.com##.ytd-rich-section-renderer.style-scope > .ytd-rich-shelf-renderer.style-scope"
      ];
    };
    "newtaboverride@agenedia.com" = {
      type = "homepage";
      focus_website = true;
    };
  };
in
{
  config = lib.mkMerge [
    (lib.mkIf cfg.brave.enable {
      programs.chromium.extensions = [
        { id = "dnhpnfgdlenaccegplpojghhmaamnnfp"; } # augmented steam
        { id = "ajopnjidmegmdimjlfnijceegpefgped"; } # betterttv
        { id = "ldpochfccmkkmhdbclfhpagapcfdljkj"; } # decentraleyes
        { id = "edibdbjcniadpccecjdfdjjppcpchdlm"; } # i-still-dont-care-about-cookies
        { id = "fkagelmloambgokoeokbpihmgpkbgbfm"; } # indie wiki buddy
        { id = "padekgcemlokbadohgkifijomclgjgif"; } # proxy switchyomega
        { id = "kbmfpngjjgdllneeigpgjifpgocmfgmb"; } # reddit enhancement suite
        { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock-origin
        { id = "jinjaccalgkegednnccohejagnlnfdag"; } # violent monkey
      ];
    })
    (lib.mkIf cfg.firefox.enable {
      programs.firefox.profiles.default.extensions = profileExtensions;
      programs.firefox.policies."3rdparty".Extensions = policyExtensions;
    })
    (lib.mkIf cfg.librewolf.enable {
      programs.librewolf.profiles.default.extensions = profileExtensions;
      programs.librewolf.policies."3rdparty".Extensions = policyExtensions;
    })
  ];
}
