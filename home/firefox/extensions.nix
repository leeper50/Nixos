{ pkgs, lib, ... }:
let
  containers = import ./containers.nix;
  cookieStoreId = name: "firefox-container-${toString containers.${name}.id}";

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
in
{
  programs.firefox.profiles.default.extensions = {
    force = true;
    packages = with pkgs.nur.repos.rycee.firefox-addons; [
      bitwarden
      containerise
      decentraleyes
      indie-wiki-buddy
      istilldontcareaboutcookies
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

  programs.firefox.policies."3rdparty".Extensions = {
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
        "x.com##.r-ttdzmv.r-vacyoi.css-175oi2r > div.css-175oi2r:nth-of-type(3)"
        "x.com##.r-ttdzmv.r-vacyoi.css-175oi2r > div.r-1udh08x.r-1ifxtd0.r-rs99b7.r-1phboty.r-1867qdf.r-jxzhtn.r-14lw9ot.css-175oi2r"
      ];
    };
    "newtaboverride@agenedia.com" = {
      type = "homepage";
      focus_website = true;
    };
  };
}
