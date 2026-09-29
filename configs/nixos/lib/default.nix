{
  config,
  globals,
  lib,
}:
{
  mkCaddyVirtualHosts = import ./caddy.nix { inherit config globals lib; };
  mkFirewallRules = import ./firewall.nix { inherit lib; };
}
