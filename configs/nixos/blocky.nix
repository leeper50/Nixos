{ globals, lib, ... }:
let
  ports.dns = 53;
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
          allowlists = {
            ads = [
              ''
                googleads.g.doubleclick.net
                pubads.g.doubleclick.net
              ''
            ];
            farRight = [
              ''
                *.x.com
                *.twitter.com
              ''
            ];
          };
          denylists = {
            ads = [
              "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/pro.txt"
            ];
            farRight = [
              "https://assets.windscribe.com/custom_blocklists/clickbait.txt"
              "https://raw.githubusercontent.com/antifa-n/pihole/master/blocklist-alttech.txt"
              "https://raw.githubusercontent.com/antifa-n/pihole/master/blocklist-pop.txt"
              "https://raw.githubusercontent.com/antifa-n/pihole/master/blocklist.txt"
              "https://raw.githubusercontent.com/DandelionSprout/adfilt/refs/heads/master/Sensitive%20lists/TabloidRemover.txt"
              "https://raw.githubusercontent.com/MassMove/AttackVectors/master/LocalJournals/fake-local-journals-list.txt"
            ];
          };
          clientGroupsBlock = {
            default = [
              "ads"
              "farRight"
            ];
          };
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
        customDNS.mapping = customDNSMapping;
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
