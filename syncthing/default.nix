{
  config,
  globals,
  lib,
  ...
}:
let
  cfg = config.local.syncthing;
  home = cfg.home;
in
{
  options.local.syncthing = {
    home = lib.mkOption {
      type = lib.types.str;
      default = "/home/${globals.username}";
    };
    folders = lib.mkOption {
      default = { };
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            enable = lib.mkEnableOption "syncthing folder";
            type = lib.mkOption {
              type = lib.types.str;
              default = "sendreceive";
            };
          };
        }
      );
    };
  };

  config = lib.mkMerge [
    {
      services.syncthing = {
        enable = true;
        guiAddress = "0.0.0.0:8384";
        settings.devices = {
          "laptop".id = "OO2HOLH-QXRS2H2-TMIJOF6-IJX7DHR-CX44KSR-AVQBAG5-5SRE73T-QGHATQQ";
          "macbook".id = "MGESDGN-2WDZUXZ-2KVQYEH-X6P7F7C-5HQGBNZ-7LYP4AC-SSSCA5I-JCOTLAX";
          "moto-g".id = "5NSRNJQ-XGLQYCX-M3ZKVYC-KDP3MMU-JJQWBBC-CSKWW6Y-FEUAHDW-YSZFQAA";
          "nas".id = "PGRFMYY-55TDV4M-5PZK35F-OOYCALV-JM5MBXK-CQZ4JEX-2VZLFBW-AFLJPAN";
          "phone".id = "LBLFNCY-MRGPFRW-XOIMRGV-T4Q57PM-CEA3YTC-P5YIPGG-3BBOH45-XLADQAL";
          "tablet".id = "XA573YH-IVZCREZ-ED4IXXO-XVVUSU2-XBXYE7P-KSREPLX-2X4AKJF-2YIQNAT";
          "workstation".id = "HMZTYV2-S3KY47A-SV67FII-75SN5JX-PGNLXYQ-JVKBLXB-3FKNC4J-PPV5SAZ";
        };
      };
    }
    (lib.mkIf (cfg.folders."Desktops".enable or false) {
      services.syncthing.settings.folders."Desktops" = {
        devices = [
          "laptop"
          "macbook"
          "workstation"
        ];
        id = "zmytz-ewbvk";
        path = "${home}/Sync/Desktops";
        type = cfg.folders."Desktops".type;
      };
    })
    (lib.mkIf (cfg.folders."Downloads".enable or false) {
      services.syncthing.settings.folders."Downloads" = {
        devices = [
          "laptop"
          "macbook"
          "workstation"
        ];
        id = "wdxge-fcb6f";
        path = "${home}/Downloads";
        type = cfg.folders."Downloads".type;
      };
    })
    (lib.mkIf (cfg.folders."FreeTube".enable or false) {
      services.syncthing.settings.folders."FreeTube" = {
        devices = [
          "laptop"
          "nas"
          "workstation"
        ];
        id = "kembu-qwjnf";
        path = "${home}/.var/app/io.freetubeapp.FreeTube/config/FreeTube";
        type = cfg.folders."FreeTube".type;
      };
    })
    (lib.mkIf (cfg.folders."GlobalShare".enable or false) {
      services.syncthing.settings.folders."GlobalShare" = {
        devices = [
          "laptop"
          "macbook"
          "moto-g"
          "nas"
          "phone"
          "tablet"
          "workstation"
        ];
        id = "urm2m-gt7xq";
        path = "${home}/Sync/GlobalShare";
        type = cfg.folders."GlobalShare".type;
      };
    })
    (lib.mkIf (cfg.folders."Notes".enable or false) {
      services.syncthing.settings.folders."Notes" = {
        devices = [
          "laptop"
          "macbook"
          "moto-g"
          "nas"
          "phone"
          "tablet"
          "workstation"
        ];
        id = "extbw-xzgpn";
        path = "${home}/Sync/Notes";
        type = cfg.folders."Notes".type;
      };
    })
    (lib.mkIf (cfg.folders."Phone".enable or false) {
      services.syncthing.settings.folders."Phone" = {
        devices = [
          "macbook"
          "phone"
          "tablet"
          "workstation"
        ];
        id = "2sfej-bdebv";
        path = "${home}/Sync/Phone";
        type = cfg.folders."Phone".type;
      };
    })
    (lib.mkIf (cfg.folders."Tablet".enable or false) {
      services.syncthing.settings.folders."Tablet" = {
        devices = [
          "laptop"
          "macbook"
          "moto-g"
          "tablet"
          "workstation"
        ];
        id = "3an97-7phbm";
        path = "${home}/Sync/Tablet";
        type = cfg.folders."Tablet".type;
      };
    })
  ];
}
