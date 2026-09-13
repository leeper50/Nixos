{
  disko,
  pkgs,
  ...
}:
{
  imports = [
    disko.nixosModules.disko
    ../k3s-disk-config.nix
  ];
  local = {
    local = true;
  };
  environment.systemPackages = [
    pkgs.fastfetch
  ];
  networking = {
    hostName = "k3s-01";
    interfaces.ens18 = {
      ipv4.addresses = [
        {
          address = "10.0.2.1";
          prefixLength = 8;
        }
      ];
      ipv6.addresses = [
        {
          address = "2600:1702:58c1:9acf::2:1";
          prefixLength = 64;
        }
      ];
    };
  };
  system.stateVersion = "26.05";
  virtualisation.libvirtd.enable = true;
}
