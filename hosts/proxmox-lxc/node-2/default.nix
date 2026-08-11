{ ... }:
{
  local.docker.swarm = {
    enable = true;
    managerIP = "node-1.local";
  };
  networking = {
    hostName = "node-2";
    interfaces.eth0 = {
      ipv4.addresses = [
        {
          address = "10.0.0.22";
          prefixLength = 8;
        }
      ];
      ipv6.addresses = [
        {
          address = "2600:1702:58c1:9acf::22";
          prefixLength = 64;
        }
      ];
    };
  };
  system.stateVersion = "25.11";
}
