{ ... }:
{
  services.nfs = {
    settings = {
      "[nfsd]" = ''
        vers2=n
        vers3=n
      '';
    };
    server = {
      enable = true;
      exports = ''
        /nfs/docker  10.0.0.0/24(rw,sync,no_subtree_check,no_root_squash,fsid=0)
      '';
    };
  };

  networking.firewall.allowedTCPPorts = [ 2049 ];

  systemd.tmpfiles.rules = [
    "d /nfs/docker 0755 root root -"
  ];
}
