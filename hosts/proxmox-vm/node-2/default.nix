{ ... }:
{
  networking = {
    hostName = "node-2";
    interfaces.ens18 = {
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
