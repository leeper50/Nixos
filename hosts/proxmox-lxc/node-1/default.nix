{ ... }:
{
  local.beszel.hub.enable = true;
  local.docker = {
    komodo = {
      core.enable = true;
      coreIP = "10.0.0.21";
      periphery.enable = true;
    };
    swarm = {
      labels = [ "amd_gpu" ];
      manager = true;
      managerIP = "10.0.0.21";
    };
  };
  networking = {
    firewall = {
      allowedTCPPorts = [
        80
        443
      ];
      allowedUDPPorts = [ 443 ];
    };
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
          address = "2600:1702:58c1:9acf::21";
          prefixLength = 64;
        }
      ];
    };
  };
  system.stateVersion = "25.11";
}
