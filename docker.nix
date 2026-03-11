{ ... }:

let
  adguard_version = "4956b35b590286e5872fb4336d84a7862a2030c6efb4ca16442580c37d7ba32d";
  storage = "/home/walter/containers";
in
{
  # networking.firewall = {
  #   allowedTCPPorts = [
  #     53
  #     3000
  #   ];
  #   allowedUDPPorts = [ 53 ];
  # };
  virtualisation = {
    docker = {
      enable = true;
      # Set up resource limits
      daemon.settings = {
        experimental = true;
        default-address-pools = [
          {
            base = "172.16.0.0/12";
            size = 24;
          }
        ];
      };
    };
  };
  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers = {
    adguard = {
      autoStart = true;
      image = "adguard/adguardhome@sha256:${adguard_version}";
      ports = [
        "53:53/tcp"
        "53:53/udp"
        "3000:3000/tcp"
      ];
      volumes = [
        "${storage}/adguardhome/work:/opt/adguardhome/work"
        "${storage}/adguardhome/conf:/opt/adguardhome/conf"
      ];
    };
  };
}
