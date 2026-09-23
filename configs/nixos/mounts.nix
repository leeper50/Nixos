{
  config,
  globals,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.local.mounts;
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
      if cfg.autoMount then
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
    (lib.mkIf (config.local.local && cfg.media) {
      fileSystems."/mnt/media" = {
        device = "nas.dellhp.party:/mnt/data/Media";
        fsType = "nfs";
        options = nfs_options;
      };
    })
    (lib.mkIf (config.local.local && cfg.user) {
      fileSystems."/mnt/${globals.username}" = {
        device = "nas.dellhp.party:/mnt/data/home/${globals.username}";
        fsType = "nfs";
        options = nfs_options;
      };
    })
  ];
}
