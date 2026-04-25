{ ... }:
{
  services.nfs = {
    settings = {
      nfsd = {
        vers2 = "n";
      };
    };
    server = {
      createMountPoints = true;
      enable = true;
      exports = ''
        /export          10.0.0.0/24(rw,fsid=0,no_subtree_check)
        /export/docker   10.0.0.0/24(rw,sync,no_subtree_check,no_root_squash)
      '';
      lockdPort = 4001;
      mountdPort = 4002;
      statdPort = 4000;
    };
  };

  systemd.tmpfiles.rules = [
    "d /export        0755 root root -"
    "d /export/docker 0777 root root -"
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
