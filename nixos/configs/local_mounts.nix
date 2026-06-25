{ pkgs, ... }:
{
  boot.supportedFilesystems = [ "nfs" ];
  fileSystems."/mnt/docker" = {
    device = "nas.local:/mnt/docker";
    fsType = "nfs";
    options = [
      "_netdev"
      "hard"
      "nfsvers=4.2"
      "nofail"
      "rw"
    ];
  };
  fileSystems."/mnt/media" = {
    device = "nas.local:/mnt/data/Media";
    fsType = "nfs";
    options = [
      "_netdev"
      "hard"
      "nfsvers=4.2"
      "nofail"
      "rw"
    ];
  };
  environment.systemPackages = with pkgs; [ nfs-utils ];
}
