{
  config,
  globals,
  hostName ? null,
  lib,
  osConfig ? null,
  systemType,
  ...
}:
let
  cfg = config.local.syncthing;
  devices = {
    all = devices.desktops ++ devices.mobiles ++ devices.servers;
    desktops = [
      "laptop"
      "macbook"
      "workstation"
    ];
    mobiles = [
      "moto-g"
      "tablet"
      "phone"
    ];
    servers = [ "nas" ];
  };
  folders = {
    "Desktops" = {
      devices = devices.desktops ++ devices.servers;
      id = "zmytz-ewbvk";
    };
    "Downloads" = {
      devices = devices.desktops ++ devices.servers;
      id = "wdxge-fcb6f";
      path = "${cfg.home}/Downloads";
    };
    "FreeTube" = {
      devices = lib.filter (name: name != "macbook") (devices.desktops ++ devices.servers);
      id = "kembu-qwjnf";
      path = "${cfg.home}/.var/app/io.freetubeapp.FreeTube/config/FreeTube";
    };
    "GlobalShare" = {
      devices = devices.all;
      id = "urm2m-gt7xq";
    };
    "Notes" = {
      devices = devices.all;
      id = "extbw-xzgpn";
    };
    "Phone" = {
      devices = devices.all;
      id = "2sfej-bdebv";
    };
    "Tablet" = {
      devices = devices.all;
      id = "3an97-7phbm";
    };
  };
  resolvedHostName =
    if systemType == "Standalone" then
      hostName
    else if osConfig != null then
      osConfig.networking.hostName
    else
      config.networking.hostName;
in
{
  options.local.syncthing = {
    folder_type = lib.mkOption {
      default = "sendreceive";
      type = lib.types.str;
    };
    home = lib.mkOption {
      default = "/home/${globals.username}";
      type = lib.types.str;
    };
  };
  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = resolvedHostName != null && lib.elem resolvedHostName devices.all;
          message = "local.syncthing: host '${toString resolvedHostName}' is not a known syncthing device";
        }
      ];
      services.syncthing = {
        enable = true;
        guiAddress = "0.0.0.0:8384";
        settings = {
          devices = {
            "laptop".id = "OO2HOLH-QXRS2H2-TMIJOF6-IJX7DHR-CX44KSR-AVQBAG5-5SRE73T-QGHATQQ";
            "macbook".id = "MGESDGN-2WDZUXZ-2KVQYEH-X6P7F7C-5HQGBNZ-7LYP4AC-SSSCA5I-JCOTLAX";
            "moto-g".id = "5NSRNJQ-XGLQYCX-M3ZKVYC-KDP3MMU-JJQWBBC-CSKWW6Y-FEUAHDW-YSZFQAA";
            "nas".id = "PGRFMYY-55TDV4M-5PZK35F-OOYCALV-JM5MBXK-CQZ4JEX-2VZLFBW-AFLJPAN";
            "phone".id = "LBLFNCY-MRGPFRW-XOIMRGV-T4Q57PM-CEA3YTC-P5YIPGG-3BBOH45-XLADQAL";
            "tablet".id = "PBXQVP4-BPXY3EV-U45PSLY-ZTYAEKP-L4VJKS5-SJ2B6EE-5DZOUKV-PZKFJQZ";
            "workstation".id = "HMZTYV2-S3KY47A-SV67FII-75SN5JX-PGNLXYQ-JVKBLXB-3FKNC4J-PPV5SAZ";
          };
          folders = lib.mapAttrs (name: folder: {
            inherit (folder) devices id;
            path = folder.path or "${cfg.home}/Sync/${name}";
            type = folder.type or cfg.folder_type;
          }) (lib.filterAttrs (_: folder: lib.elem resolvedHostName folder.devices) folders);
        };
      };
    }
    (lib.optionalAttrs (systemType == "Nixos") {
      services.syncthing = {
        guiPasswordFile = config.age.secrets."user_${globals.username}_clear.age".path;
        settings.gui.user = globals.username;
      };
    })
    (lib.optionalAttrs (systemType != "Nixos") {
      services.syncthing.guiCredentials = {
        passwordFile = config.age.secrets."user_${globals.username}_clear.age".path;
        username = globals.username;
      };
    })
  ];
}
