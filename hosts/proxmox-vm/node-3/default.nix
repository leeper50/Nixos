{ ... }:
{
  networking = {
    hostName = "node-3";
    interfaces.ens18 = {
      ipv4.addresses = [
        {
          address = "10.0.0.23";
          prefixLength = 8;
        }
      ];
    };
  };
  system.stateVersion = "25.11";
}
