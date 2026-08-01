{ globals, ... }:
let
  ports.dns = 53;
in
{
  networking.firewall = {
    allowedTCPPorts = [ ports.dns ];
    allowedUDPPorts = [ ports.dns ];
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
                *.cbsavideo.com
                *.cbsi.com
                *.cbsi.live.ott.irdeto.com
                *.cbsig.net
                *.cbsinteractive.hb.omtrdc.net
                *.cbsstatic.com
                *.paramount.tech
                *.paramountplus.com
                *.pplusstatic.com
                *.tiqcdn.com
              ''
              "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/whitelist-referral.txt"
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
        bootstrapDns = globals.nameservers.public;
        caching = {
          prefetching = true;
          prefetchExpires = "24h";
          prefetchThreshold = 2;
        };
        customDNS = {
          mapping = {
            "buncha.men" = "10.0.1.1,2600:1702:58c1:9acf::1:1";
            "dellhplaptop.xyz" = "10.0.0.60,2600:1702:58c1:9acf::60";
            "dns01.home.local" = "10.0.0.31,2600:1702:58c1:9acf::31";
            "dns02.home.local" = "10.0.0.32,2600:1702:58c1:9acf::32";
            "dns03.home.local" = "10.0.0.33,2600:1702:58c1:9acf::33";
            "tplinkwifi.net" = "10.0.0.1,2600:1702:58c1:9acf:f2a7:31ff:fe94:abac";
          };
        };
        ports.dns = ports.dns;
        queryLog.type = "none";
        upstreams = {
          groups = {
            default = [
              "https://dns.quad9.net/dns-query"
              "https://1.1.1.1/dns-query"
            ];
          };
          strategy = "parallel_best";
          timeout = "2s";
        };
      };
    };
    resolved.enable = false;
  };
}
