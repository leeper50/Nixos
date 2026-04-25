{ ... }:
{
  services.nfs = {
    settings = {
      nfsd = {
        vers2 = "n";
        vers3 = "n";
      };
    };
    server = {
      createMountPoints = true;
      enable = true;
      exports = ''
        /nfs          10.0.0.0/24(ro,fsid=0,no_subtree_check)
        /nfs/docker   10.0.0.0/24(rw,sync,no_subtree_check,no_root_squash)
      '';
    };
  };

  networking.firewall.allowedTCPPorts = [ 2049 ];
}
