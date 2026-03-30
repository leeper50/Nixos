{ pkgs, ... }:
{
  services.netbird = {
    enable = true;
    package = pkgs.unstable.netbird;
  };
}
