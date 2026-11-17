{
  config,
  globals,
  lib,
  pkgs,
  secrets,
  ...
}:
let
  cfg = config.local.mounts;
  nas = "nas.${globals.domains.primary}";
  credentialsDir = "/run/smb-credentials";
  passwordSecret = user: "user_${user}_clear.age";
  common_options = [
    "_netdev"
    "hard"
    "nofail"
    "rw"
  ]
  ++ (
    if cfg.autoMount then
      [
        "noauto"
        "x-systemd.automount"
        "x-systemd.idle-timeout=600"
      ]
    else
      [ "x-systemd.mount-timeout=infinity" ]
  );
  mountOptions = {
    nfs =
      _share:
      common_options
      ++ [
        "nfsvers=4.2"
        "retrans=2"
        "timeo=600"
      ]
      ++ lib.optional (!cfg.autoMount) "retry=10000";
    cifs =
      share:
      common_options
      ++ [
        "credentials=${credentialsDir}/${share.user}"
        "posix"
        "seal"
        "vers=3.1.1"
        "x-systemd.requires=smb-credentials-${share.user}.service"
      ];
  };
  shares = {
    media = {
      cifs = "//${nas}/Media";
      local = "/mnt/media";
      nfs = "${nas}:/mnt/data/Media";
    };
    walter = {
      cifs = "//${nas}/walter";
      local = "/home/walter/Nas";
      nfs = "${nas}:/mnt/data/home/walter";
    };
  };
  enabled = lib.filterAttrs (_: share: share.enable) cfg.shares;
  usesProtocol = protocol: lib.any (share: share.protocol == protocol) (lib.attrValues enabled);
  smbUsers = lib.unique (
    map (share: share.user) (lib.filter (share: share.protocol == "cifs") (lib.attrValues enabled))
  );
in
{
  options.local.mounts = {
    autoMount = lib.mkEnableOption "automount";
    shares = lib.mapAttrs (name: _: {
      enable = lib.mkEnableOption "the ${name} nas share";
      protocol = lib.mkOption {
        type = lib.types.enum [
          "cifs"
          "nfs"
        ];
        default = "nfs";
        description = "Protocol used to mount the ${name} share.";
      };
      user = lib.mkOption {
        type = lib.types.enum (lib.attrNames config.local.users);
        default = "walter";
        description = "Nas user the ${name} share logs in as when mounted over samba.";
      };
    }) shares;
  };
  config = lib.mkIf config.local.local (
    lib.mkMerge [
      {
        fileSystems = lib.mapAttrs' (
          name: share:
          lib.nameValuePair shares.${name}.local {
            device = shares.${name}.${share.protocol};
            fsType = share.protocol;
            options = mountOptions.${share.protocol} share;
          }
        ) enabled;
      }
      (lib.mkIf (usesProtocol "nfs") {
        boot.supportedFilesystems = [ "nfs" ];
        environment.systemPackages = [ pkgs.nfs-utils ];
      })
      (lib.mkIf (usesProtocol "cifs") {
        age.secrets = lib.genAttrs (map passwordSecret smbUsers) (name: {
          file = "${secrets}/${name}";
        });
        boot.supportedFilesystems = [ "cifs" ];
        environment.systemPackages = [ pkgs.cifs-utils ];
        # Build per-user smb-credentials files from the
        # samba server's registered user passwords
        systemd.services = lib.listToAttrs (
          map (
            user:
            lib.nameValuePair "smb-credentials-${user}" {
              description = "Samba credentials for ${user}";
              serviceConfig = {
                RemainAfterExit = true;
                Type = "oneshot";
                UMask = "0077";
              };
              script = ''
                mkdir -p ${credentialsDir}
                printf 'username=%s\npassword=%s\n' ${user} "$(< ${
                  config.age.secrets.${passwordSecret user}.path
                })" > ${credentialsDir}/${user}
              '';
            }
          ) smbUsers
        );
      })
    ]
  );
}
