{ globals, ... }:
{
  services.nfs = {
    settings = {
      nfsd = {
        vers2 = "n";
        vers3 = "y";
        vers4 = "y";
        "vers4.2" = "y";
      };
    };
    server = {
      createMountPoints = true;
      enable = true;
      exports = ''
        /mnt/docker      10.0.0.0/24(rw,sync,no_subtree_check,no_root_squash)
        /mnt/docker      2600:1702:58c1:9acf::/64(rw,sync,no_subtree_check,no_root_squash)
        /mnt/data/Media  10.0.0.0/24(rw,sync,no_subtree_check,root_squash)
        /mnt/data/Media  2600:1702:58c1:9acf::/64(rw,sync,no_subtree_check,root_squash)
        /mnt/data/home/${globals.username}  10.0.0.0/24(rw,sync,no_subtree_check,root_squash)
        /mnt/data/home/${globals.username}  2600:1702:58c1:9acf::/64(rw,sync,no_subtree_check,root_squash)
      '';
      lockdPort = 4001;
      mountdPort = 4002;
      nproc = 16;
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
    ];
    allowedUDPPorts = [
      111
      2049
      4000
      4001
      4002
    ];
  };
}
