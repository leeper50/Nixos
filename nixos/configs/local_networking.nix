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
      "10.0.0.40" # Scuffed Virtual IP
      "10.0.1.1" # Swarm Virtual IP
      "9.9.9.9"
      "2600:1702:58c1:9acd:be24:11ff:fe47:b25d"
      "2600:1702:58c1:9acd:be24:11ff:fe5b:23bd"
    ];
    networkmanager.enable = true;
    nftables.enable = true;
  };
}
