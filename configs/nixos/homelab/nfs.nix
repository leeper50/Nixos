{
  globals,
  lib,
  localLib,
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
  sources = globals.networking.lan.subnets ++ globals.networking.tailscale.subnet;
  exportTo =
    path:
    "${path} " + lib.concatMapStringsSep " " (s: "${s}(rw,sync,no_subtree_check,root_squash)") sources;
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
        ${exportTo "/mnt/data/home/walter"}
        ${exportTo "/mnt/data/Media"}
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
  systemd.tmpfiles.rules = [ "f /var/lib/nfs/etab 0644 root root -" ];
  networking.firewall = localLib.mkFirewallRules {
    service = "nfs";
    sources = globals.networking.lan.subnets;
    tcpPorts = lib.attrValues ports;
    udpPorts = lib.attrValues ports;
  };
}
