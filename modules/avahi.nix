{ ... }:
{
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    nssmdns6 = false;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      workstation = true;
    };
  };
}
