{
  globals,
  lib,
  pkgs,
  ...
}:
let
  ports = {
    lockd = 4001;
    mountd = 4002;
    nfsd = 2049;
    rpcbind = 111;
    statd = 4000;
  };
in
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
        # Home Dir
        /mnt/data/home/${globals.username} ${globals.networking.ipv4.lanSubnet}(rw,sync,no_subtree_check,root_squash)
        /mnt/data/home/${globals.username} ${globals.networking.ipv6.lanSubnet}(rw,sync,no_subtree_check,root_squash)
        # Media Dir
        /mnt/data/Media ${globals.networking.ipv4.lanSubnet}(rw,sync,no_subtree_check,root_squash)
        /mnt/data/Media ${globals.networking.ipv6.lanSubnet}(rw,sync,no_subtree_check,root_squash)
      '';
      lockdPort = ports.lockd;
      mountdPort = ports.mountd;
      nproc = 16;
      statdPort = ports.statd;
    };
  };
  systemd.services = lib.mkMerge [
    (lib.genAttrs [ "nfs-server" "nfs-mountd" ] (_: {
      unitConfig.RequiresMountsFor = [ "/mnt/data" ];
    }))
    { nfs-server.path = [ pkgs.kmod ]; }
  ];
  networking.firewall = globals.mkFirewallRules {
    service = "nfs";
    sources = [
      globals.networking.ipv4.lanSubnet
      globals.networking.ipv6.lanSubnet
    ];
    tcpPorts = lib.attrValues ports;
    udpPorts = lib.attrValues ports;
  };
}
