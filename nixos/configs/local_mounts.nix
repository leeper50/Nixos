{ pkgs, ... }:
{
  boot.supportedFilesystems = [ "nfs" ];
  fileSystems."/mnt/docker" = {
    device = "nas.local:/mnt/docker";
    fsType = "nfs";
    options = [
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
  };
  fileSystems."/mnt/media" = {
    device = "nas.local:/mnt/data/Media";
    fsType = "nfs";
    options = [
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
  };
  environment.systemPackages = with pkgs; [ nfs-utils ];
}
