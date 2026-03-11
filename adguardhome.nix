{ config, pkgs, ... }:
in
{
  adguardhome = {
    enable = true;
    openFirewall = true;
  };
}
