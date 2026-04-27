{
  config,
  pkgs,
  ...
}:

{
  boot.supportedFilesystems = [ "nfs" ];
  environment.systemPackages = with pkgs; [
    cifs-utils
    k3s
    nfs-utils
    openiscsi
  ];
  networking.firewall = {
    allowedTCPPorts = [
      # k3s
      2379 # etcd client
      2380 # etcd peer
      6443 # k3s API server
      10250 # kubelet metrics
      10251 # k3s scheduler
      10252 # k3s controller manager

      # Flannel CNI (k3s default)
      8472 # VXLAN - needs UDP too (see below)

      # Longhorn
      9500 # longhorn-manager API (longhorn-backend)
      9501 # longhorn-manager internal
      9502 # longhorn-admission-webhook ← this is your immediate problem
      9503 # longhorn-conversion-webhook

      # iSCSI
      3260
    ];
    allowedUDPPorts = [
      8472 # Flannel VXLAN
      51820 # WireGuard (if using k3s with WireGuard flannel backend)
    ];
  };
  services.k3s = {
    enable = true;
    role = "server";
    tokenFile = config.age.secrets."k3s_token.age".path;
    extraFlags = toString (
      [
        "--write-kubeconfig-mode \"0644\""
        "--cluster-init"
        "--disable servicelb"
        "--disable traefik"
        "--disable local-storage"
      ]
      ++ (
        if config.networking.hostName == "node-1" then
          [ ]
        else
          [
            "--server https://node-1.local:6443"
          ]
      )
    );
    clusterInit = (config.networking.hostName == "node-1");
  };
  services.openiscsi = {
    enable = true;
    name = "iqn.2020-08.org.linux-iscsi.${config.networking.hostName}.local:storage";
  };
  services.rpcbind.enable = true;
  systemd.tmpfiles.rules = [
    "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
  ];
  virtualisation.docker.logDriver = "json-file";
}
