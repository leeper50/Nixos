{ ... }:
{
  services.nfs = {
    settings = {
      nfsd = {
        vers2 = "n";
        vers4 = "n";
      };
    };
    server = {
      createMountPoints = true;
      enable = true;
      exports = ''
        /mnt/docker      10.0.0.0/24(rw,sync,no_subtree_check,no_root_squash)
        /mnt/data/Media  10.0.0.0/24(rw,sync,no_subtree_check,root_squash)
      '';
      lockdPort = 4001;
      mountdPort = 4002;
      statdPort = 4000;
    };
  };

  systemd.tmpfiles.rules = [
    "d /mnt/docker 0777 root root -"
  ];

  networking.firewall = {
    allowedTCPPorts = [
      111
      2049
      4000
      4001
      4002
      20048
    ];
    allowedUDPPorts = [
      111
      2049
      4000
      4001
      4002
      20048
    ];
  };
}
