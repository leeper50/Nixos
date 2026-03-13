{ ... }:
{
  networking = {
    defaultGateway = "10.0.0.1";
    firewall = {
      allowPing = true;
      enable = true;
    };
    nameservers = [
      "10.0.0.40"
      "10.0.0.1"
      "9.9.9.9"
    ];
    networkmanager.enable = true;
    nftables.enable = true;
  };
}
