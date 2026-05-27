{ ... }:
{
  networking = {
    hostName = "node-1";
    interfaces.eth0 = {
      ipv4.addresses = [
        {
          address = "10.0.0.21";
          prefixLength = 8;
        }
      ];
    };
  };
  system.stateVersion = "25.11";
}
