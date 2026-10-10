{
  config,
  globals,
  lib,
  systemType,
  pkgs,
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
      ignores = [
        "(?d).idea/workspace.xml"
        "(?d)*.aux"
        "(?d)*.class"
        "(?d)*.exe"
        "(?d)*.fdb_latexmk"
        "(?d)*.fls"
        "(?d)*.synctex.gz"
        "(?d)/Programs/Typescript/NewWebsite/build"
        "(?d)a.out"
      ];
    };
    "Downloads" = {
      devices = devices.desktops ++ devices.servers;
      id = "wdxge-fcb6f";
      ignores = [
        "(?d)*.crdownload"
        "(?d)*.surge"
        "(?d)*.part"
      ];
      path = "${cfg.home}/Downloads";
    };
    "FreeTube" = {
      devices = lib.filter (name: name != "macbook") (devices.desktops ++ devices.servers);
      id = "kembu-qwjnf";
      ignores = [
        "(?i)*cache"
        "SingletonCookie"
        "SingletonLock"
        "SingletonSocket"
      ];
      path = "${cfg.home}/.var/app/io.freetubeapp.FreeTube/config/FreeTube";
    };
    "GlobalShare" = {
      devices = devices.all;
      id = "urm2m-gt7xq";
      ignores = [ "~$*.xlsx" ];
    };
    "Notes" = {
      devices = devices.all;
      id = "extbw-xzgpn";
      ignores = [
        ".obsidian/workspace-mobile.json"
        ".obsidian/workspace.json"
      ];
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
  defaultIgnores = [
    ".git"
    "(?d)__pycache__"
    "(?d)._*"
    "(?d).DS_Store"
    "(?d).svelte-kit"
    "(?d).terraform"
    "(?d).Trash-*"
    "(?d).venv"
    "(?d)*.pyc"
    "(?d)desktop.ini"
    "(?d)node_modules"
    "(?d)Thumbs.db"
    "(?d)venv"
  ];
  enabledFolders = lib.mapAttrs (name: folder: {
    inherit (folder) devices id;
    ignores = defaultIgnores ++ folder.ignores or [ ];
    path = folder.path or "${cfg.home}/Sync/${name}";
    type = folder.type or cfg.folder_type;
  }) (lib.filterAttrs (_: folder: lib.elem globals.hostName folder.devices) folders);
  buildStignore = pkgs.writeShellApplication {
    name = "build-stignore";
    text = ''
      # write_stglobalignore <folder path> <pattern>...
      write_stglobalignore() {
        local dir="$1"
        shift
        mkdir -p "$dir"
        rm -f "$dir/.stignore"
        rm -f "$dir/.stglobalignore"
        printf '%s\n' "#include .stglobalignore" > "$dir/.stignore"
        printf '%s\n' "$@" > "$dir/.stglobalignore"
      }

      # write_stignore <folder path> <pattern>...
      # For receiveonly folders:
      # .stignore is never synced, so write the patterns there
      write_stignore() {
        local dir="$1"
        shift
        mkdir -p "$dir"
        rm -f "$dir/.stignore"
        printf '%s\n' "$@" > "$dir/.stignore"
      }

    ''
    + lib.concatStrings (
      lib.mapAttrsToList (_: folder: ''
        ${
          if folder.type == "receiveonly" then "write_stignore" else "write_stglobalignore"
        } ${lib.escapeShellArg folder.path} ${lib.escapeShellArgs folder.ignores}
      '') enabledFolders
    );
  };
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
          assertion = globals.hostName != null && lib.elem globals.hostName devices.all;
          message = "local.syncthing: host '${toString globals.hostName}' is not a known syncthing device";
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
          folders = lib.mapAttrs (_: folder: {
            inherit (folder)
              devices
              id
              path
              type
              ;
          }) enabledFolders;
        };
      };
    }
    (lib.optionalAttrs (systemType == "Nixos") {
      services.syncthing = {
        guiPasswordFile = config.age.secrets."user_${globals.username}_clear.age".path;
        settings.gui.user = globals.username;
      };
      systemd.services.build-stignore = {
        description = "Populate .stignore files for all shares.";
        before = [ "syncthing.service" ];
        wantedBy = [ "syncthing.service" ];
        serviceConfig = {
          ExecStart = lib.getExe buildStignore;
          Group = config.services.syncthing.group;
          RemainAfterExit = true;
          Type = "oneshot";
          User = config.services.syncthing.user;
        };
      };
    })
    (lib.optionalAttrs (systemType == "Standalone") {
      systemd.user.services.build-stignore = {
        Unit = {
          Description = "Populate .stignore files for all shares.";
          Before = [ "syncthing.service" ];
        };
        Service = {
          ExecStart = lib.getExe buildStignore;
          RemainAfterExit = true;
          Type = "oneshot";
        };
        Install.WantedBy = [ "default.target" ];
      };
    })
    (lib.optionalAttrs (systemType == "NixDarwin") {
      launchd.agents.build-stignore = {
        enable = true;
        config = {
          ProgramArguments = [ (lib.getExe buildStignore) ];
          RunAtLoad = true;
        };
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
