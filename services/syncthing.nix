{ config, ... }:
let
  data = "/mnt/data/SambaHomes/walter";
in
{
  networking.firewall.allowedTCPPorts = [ 8384 ];
  services.syncthing = {
    enable = true;
    guiAddress = "10.0.0.33:8384";
    openDefaultPorts = true;
    settings = {
      gui = {
        user = "walter";
        guiPasswordFile = config.age.secrets."user_walter_clear.age".path;
      };
      devices = {
        "walter-laptop" = {
          id = "I6OKPJS-YLFUWSN-GRHUNMS-2R2JJTH-UOB737Y-N6CBWX5-6DJXTDA-BUVWNA2";
        };
        "walter-macbook" = {
          id = "MGESDGN-2WDZUXZ-2KVQYEH-X6P7F7C-5HQGBNZ-7LYP4AC-SSSCA5I-JCOTLAX";
        };
        "walter-moto-g" = {
          id = "5NSRNJQ-XGLQYCX-M3ZKVYC-KDP3MMU-JJQWBBC-CSKWW6Y-FEUAHDW-YSZFQAA";
        };
        "walter-pc" = {
          id = "T5KTZL6-BUZN36J-DREEJ32-LYWWLT2-FYAJBMI-PYW7JG5-NB5RFZB-ICGVMQ5";
        };
        "walter-phone" = {
          id = "LBLFNCY-MRGPFRW-XOIMRGV-T4Q57PM-CEA3YTC-P5YIPGG-3BBOH45-XLADQAL";
        };
        "walter-tablet" = {
          id = "XA573YH-IVZCREZ-ED4IXXO-XVVUSU2-XBXYE7P-KSREPLX-2X4AKJF-2YIQNAT";
        };
      };
      folders = {
        "GlobalShare" = {
          devices = [
            "walter-laptop"
            "walter-macbook"
            "walter-moto-g"
            "walter-pc"
            "walter-phone"
            "walter-tablet"
          ];
          id = "urm2m-gt7xq";
          path = "${data}/Sync/GlobalShare";
          type = "receiveonly";
        };
      };
    };
  };
}
