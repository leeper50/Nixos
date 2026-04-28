{ ... }:
{
  networking = {
    hostName = "node-4";
    interfaces.ens18 = {
      ipv4.addresses = [
        {
          address = "10.0.0.24";
          prefixLength = 8;
        }
      ];
    };
  };
  system.stateVersion = "25.11";
}
