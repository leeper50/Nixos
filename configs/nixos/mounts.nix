{
  config,
  globals,
  lib,
  pkgs,
  ...
}:
let
  nfs_common = [
    "_netdev"
    "hard"
    "nfsvers=4.2"
    "nofail"
    "retrans=2"
    "rw"
    "timeo=600"
  ];
  nfs_options =
    nfs_common
    ++ (
      if config.local.mounts.autoMount then
        [
          "noauto" # don't mount on boot
          "x-systemd.automount" # mount when accessed
          "x-systemd.idle-timeout=600" # disconnect if unused
        ]
      else
        [
          "x-systemd.mount-timeout=infinity"
          "retry=10000"
        ]
    );
in
{
  options.local.mounts = {
    autoMount = lib.mkEnableOption "automount";
    media = lib.mkEnableOption "media";
    user = lib.mkEnableOption "user";
  };
  config = lib.mkMerge [
    (lib.mkIf config.local.local {
      boot.supportedFilesystems = [
        "nfs"
      ];
      environment.systemPackages = with pkgs; [
        nfs-utils
      ];
    })
    (lib.mkIf (config.local.local && config.local.mounts.media) {
      fileSystems."/mnt/media" = {
        device = "nas.${globals.domains.primary}:/mnt/data/Media";
        fsType = "nfs";
        options = nfs_options;
      };
    })
    (lib.mkIf (config.local.local && config.local.mounts.user) {
      fileSystems."/mnt/walter" = {
        device = "nas.${globals.domains.primary}:/mnt/data/home/walter";
        fsType = "nfs";
        options = nfs_options;
      };
    })
  ];
}
