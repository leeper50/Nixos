{ ... }:
{
  networking = {
    defaultGateway.address = "10.0.0.1";
    defaultGateway6.address = "2600:1702:58c1:9acd:f2a7:31ff:fe94:abac";
    firewall = {
      allowPing = true;
      enable = true;
    };
    nameservers = [
      # Scuffed Virtual IP
      "10.0.0.40"
      "2600:1702:58c1:9acd::40"

      # Swarm Virtual IP
      "10.0.1.1"
      "2600:1702:58c1:9acd::1:1"

      # Quad9
      "9.9.9.9"
      "2620:fe::fe"
    ];
    networkmanager.enable = true;
    nftables.enable = true;
  };
}
