{ ... }:
{
  networking = {
    hostName = "node-2";
    defaultGateway = {
      address = "10.0.0.1";
      interface = "eth0";
    };
    interfaces.eth0 = {
      ipv4.addresses = [
        {
          address = "10.0.0.22";
          prefixLength = 8;
        }
      ];
    };
  };
  system.stateVersion = "25.11";
}
