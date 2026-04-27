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
  networking.firewall.allowedTCPPorts = [
    2379
    2380
    6443
  ];
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
