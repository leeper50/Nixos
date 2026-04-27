{
  config,
  pkgs,
  ...
}:

{
  systemd.tmpfiles.rules = [
    "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
  ];
  virtualisation.docker.logDriver = "json-file";

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
            "--server https://node-1:6443"
          ]
      )
    );
    clusterInit = (config.networking.hostName == "node-1");
  };

  services.openiscsi = {
    enable = true;
    name = "iqn.2016-04.com.open-iscsi:${config.networking.hostName}";
  };

  environment.systemPackages = with pkgs; [
    k3s
    cifs-utils
    nfs-utils
  ];
}
