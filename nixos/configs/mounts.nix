{
  config,
  globals,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.local.mounts;
  nfs_options = [
    "_netdev"
    "bg"
    "hard"
    "nfsvers=4.2"
    "noauto"
    "nofail"
    "retrans=2"
    "rw"
    "timeo=600"
    "x-systemd.automount"
    "x-systemd.idle-timeout=600"
  ];
in
{
  options.local.mounts = {
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
