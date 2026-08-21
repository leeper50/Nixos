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
    docker = lib.mkEnableOption "docker";
    media = lib.mkEnableOption "media";
    user = lib.mkEnableOption "user";
  };
  config = lib.mkMerge [
    {
      boot.supportedFilesystems = [
        "nfs"
      ];
      environment.systemPackages = with pkgs; [
        nfs-utils
      ];
    }
    (lib.mkIf cfg.docker {
      fileSystems."/mnt/docker" = {
        device = "nas.local:/mnt/docker";
        fsType = "nfs";
        options = nfs_options;
      };
    })
    (lib.mkIf cfg.media {
      fileSystems."/mnt/media" = {
        device = "nas.local:/mnt/data/Media";
        fsType = "nfs";
        options = nfs_options;
      };
    })
    (lib.mkIf cfg.user {
      fileSystems."/mnt/${globals.username}" = {
        device = "nas.local:/mnt/data/home/${globals.username}";
        fsType = "nfs";
        options = nfs_options;
      };
    })
  ];
}
