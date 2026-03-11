{ ... }:

let
  adguard_version = "4956b35b590286e5872fb4336d84a7862a2030c6efb4ca16442580c37d7ba32d";
  storage = "/home/walter/podman";
in
{
  networking.firewall = {
    allowedTCPPorts = [
      53
      3000
      5300
    ];
    allowedUDPPorts = [ 53 5300 ];
  };
  networking = {
    firewall.extraCommands = ''
      iptables -A PREROUTING -t nat -i enp1s0 -p TCP --dport 53 -j REDIRECT --to-port 5300
      iptables -A PREROUTING -t nat -i enp1s0 -p UDP --dport 53 -j REDIRECT --to-port 5300
    '';
  };
  virtualisation = {
    podman = {
      enable = true;
      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };
  virtualisation.oci-containers.backend = "podman";
  virtualisation.oci-containers.containers = {
    adguard = {
      autoStart = true;
      capabilities = {
        CAP_NET_BIND_SERVICE = true;
      };
      image = "adguard/adguardhome@sha256:${adguard_version}";
      ports = [
        "0.0.0.0:5300:53/tcp"
        "0.0.0.0:5300:53/udp"
        "0.0.0.0:3000:3000/tcp"
      ];
      volumes = [
        "${storage}/adguard/work:/opt/adguardhome/work"
        "${storage}/adguard/conf:/opt/adguardhome/conf"
      ];
    };
  };
}
