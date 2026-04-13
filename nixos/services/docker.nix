{ ... }:
{
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      default-address-pools = [
        {
          base = "172.30.0.0/16";
          size = 24;
        }
        {
          base = "fd06:6a55:3bd2:ed3d::/64";
          size = 120;
        }
      ];
      experimental = true;
      fixed-cidr-v6 = "fda3:db28:76bb:e314::/64";
      ipv6 = true;
      ip6tables = true;
    };
  };
  users.users.walter.extraGroups = [ "docker" ];
}
