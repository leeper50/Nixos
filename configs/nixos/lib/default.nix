{
  config,
  globals,
  lib,
}:
{
  mkCaddyVirtualHosts = import ./caddy.nix { inherit config globals lib; };
}
