# Build caddy virtualHosts for each subdomain on the device's LAN and tailnet domains.
# A subdomain is either its caddy config, or { extraConfig; ipFilter; } where ipFilter
# names a client_ip snippet from caddy.nix ("local_ips" by default, "friendly_ips", or
# null for unrestricted). The filter only applies to the LAN domain, not the tailnet.
# e.g. localLib.mkCaddyVirtualHosts {
#   sync = "reverse_proxy 127.0.0.1:8384";
#   n = { extraConfig = "reverse_proxy 127.0.0.1:2586"; ipFilter = "friendly_ips"; };
# }
{
  config,
  globals,
  lib,
}:
subdomains:
let
  withFilter =
    extraConfig: ipFilter:
    if ipFilter == null then
      extraConfig
    else
      assert lib.assertOneOf "ipFilter" ipFilter [
        "local_ips"
        "friendly_ips"
      ];
      ''
        import ${ipFilter}
        handle @${ipFilter} {
          ${extraConfig}
        }
        handle {
          abort
        }
      '';
  mkHosts =
    domain: filtered:
    lib.mapAttrsToList (
      subdomain: value:
      let
        opts = if lib.isString value then { extraConfig = value; } else value;
      in
      lib.nameValuePair "${subdomain}.${domain}" {
        extraConfig =
          if filtered then withFilter opts.extraConfig (opts.ipFilter or "local_ips") else opts.extraConfig;
        useACMEHost = domain;
      }
    ) subdomains;
in
lib.listToAttrs (
  (mkHosts config.local.caddy.domain true)
  ++ lib.optionals config.services.tailscale.enable (mkHosts globals.domains.deviceTailnet false)
)
