{ ... }:
{
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    nssmdns6 = true;
    openFirewall = true;
    publish = {
      addresses = true;
      domain = true;
      enable = true;
      workstation = true;
    };
  };
}
