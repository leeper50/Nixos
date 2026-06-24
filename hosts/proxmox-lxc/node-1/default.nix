{ ... }:
{
  networking = {
    defaultGateway6.interface = "eth0";
    hostName = "node-1";
    interfaces.eth0 = {
      ipv4.addresses = [
        {
          address = "10.0.0.21";
          prefixLength = 8;
        }
      ];
      ipv6.addresses = [
        {
          address = "2600:1702:58c1:9acd::21";
          prefixLength = 64;
        }
      ];
    };
  };
  system.stateVersion = "25.11";
}
