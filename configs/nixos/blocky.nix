{ globals, lib, ... }:
let
  ports.dns = 53;
  dns-lists = import ./lib/dns-lists.nix;
  groupByCategory =
    f: lists: lib.zipAttrsWith (_: lib.id) (map (l: { ${l.category} = f l; }) lists);
  allowlists = groupByCategory (
    l: lib.concatMapStrings (domain: "*.${domain}\n") l.domains
  ) dns-lists.allowlists;
  denylists = groupByCategory (l: l.url.blocky or l.url) dns-lists.blocklists;
  customDNSMapping = lib.mapAttrs (
    domain: ips: lib.concatStringsSep "," ips
  ) globals.networking.hosts;
  dnsSources = [
    globals.networking.ipv4.lanSubnet
    globals.networking.docker.ipv4Subnet
    globals.networking.ipv6.lanSubnet
    globals.networking.docker.ipv6Subnet
    globals.networking.docker.fixedv6Subnet
  ];
in
{
  assertions = map (category: {
    assertion = denylists ? ${category};
    message = "dns-lists.nix: allowlist category '${category}' has no matching blocklist.";
  }) (lib.attrNames allowlists);
  networking.firewall = globals.mkFirewallRules {
    service = "blocky";
    sources = dnsSources;
    tcpPorts = [ ports.dns ];
    udpPorts = [ ports.dns ];
  };
  services = {
    blocky = {
      enable = true;
      enableConfigCheck = true;
      settings = {
        blocking = {
          inherit allowlists denylists;
          clientGroupsBlock.default = lib.attrNames denylists;
          blockType = "zeroIp";
          blockTTL = "1m";
          loading = {
            refreshPeriod = "6h";
            downloads = {
              timeout = "60s";
              attempts = 5;
              cooldown = "10s";
            };
            strategy = "fast";
            maxErrorsPerSource = 5;
          };
        };
        bootstrapDns = globals.networking.nameservers.public;
        caching = {
          prefetching = true;
          prefetchExpires = "24h";
          prefetchThreshold = 2;
        };
        customDNS = {
          mapping = customDNSMapping;
          filterUnmappedTypes = false;
        };
        ports.dns = ports.dns;
        queryLog.type = "none";
        upstreams = {
          groups.default = globals.networking.nameservers.doh;
          strategy = "parallel_best";
          timeout = "2s";
        };
      };
    };
    resolved.enable = false;
  };
}
