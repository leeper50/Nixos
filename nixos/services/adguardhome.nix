{ globals, lib, ... }:
let
  customDNS = {
    "buncha.men" = [
      "10.0.1.1"
      "2600:1702:58c1:9acf::1:1"
    ];
    "dellhplaptop.xyz" = [
      "10.0.0.60"
      "2600:1702:58c1:9acf::60"
    ];
    "tplinkwifi.net" = [
      "10.0.0.1"
      "2600:1702:58c1:9acf:f2a7:31ff:fe94:abac"
    ];
  };
  rewrites = lib.concatLists (
    lib.mapAttrsToList (
      domain: answers:
      lib.concatMap (answer: [
        {
          inherit domain answer;
          enabled = true;
        }
        {
          domain = "*.${domain}";
          inherit answer;
          enabled = true;
        }
      ]) answers
    ) customDNS
  );
  defaultClientSettings = {
    filtering_enabled = true;
    parental_enabled = false;
    safe_search.enabled = false;
    safebrowsing_enabled = false;
    upstreams = [ ];
    use_global_blocked_services = true;
    use_global_settings = true;
  };
  taggedClients = [
    {
      ids = [ "10.0.0.102" ];
      name = "Living Room TV";
      tags = [ "device_tv" ];
    }
    {
      ids = [
        "10.0.0.100"
        "2600:1702:58c1:9acf:17bc:ab1e:d339:8b1d"
        "2600:1702:58c1:9acf:8ab3:f0d8:32b3:6ede"
      ];
      name = "Master Bedroom TV";
      tags = [ "device_tv" ];
    }
    {
      ids = [
        "10.0.0.213"
        "2600:1702:58c1:9acf:2caf:100f:e8cd:86d3"
        "2600:1702:58c1:9acf:f06e:4766:68f8:96ae"
        "2600:1702:58c1:9acf:cda7:35e4:827c:507a"
      ];
      name = "Den TV";
      tags = [ "device_tv" ];
    }
  ];
in
{
  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };
  services = {
    adguardhome = {
      enable = true;
      host = "0.0.0.0";
      mutableSettings = true;
      openFirewall = true;
      port = 3000;
      settings = {
        clients = {
          persistent = map (c: defaultClientSettings // c) taggedClients;
        };
        dns = {
          bind_hosts = [ "0.0.0.0" ];
          bootstrap_dns = globals.nameservers;
          cache_enabled = true;
          cache_optimistic = true;
          cache_size = 4194304;
          hostsfile_enabled = false;
          port = 53;
          ratelimit = 0;
          upstream_dns = [
            "https://dns.quad9.net/dns-query"
            "https://1.1.1.1/dns-query"
          ];
          upstream_mode = "parallel";
          upstream_timeout = "2s";
        };
        filtering = {
          blocked_response_ttl = 60;
          blocking_mode = "null_ip";
          filtering_enabled = true;
          filters_update_interval = 6;
          parental_enabled = false;
          protection_enabled = true;
          rewrites_enabled = true;
          inherit rewrites;
          safe_search.enabled = false;
          safebrowsing_enabled = false;
        };
        filters = [
          {
            enabled = true;
            id = 1;
            name = "HaGeZi Pro";
            url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.txt";
          }
          {
            enabled = true;
            id = 2;
            name = "HaGeZi Allowlist Referral";
            url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/whitelist-referral.txt";
          }
          {
            enabled = true;
            id = 3;
            name = "Windscribe Clickbait";
            url = "https://assets.windscribe.com/custom_blocklists/clickbait.txt";
          }
          {
            enabled = true;
            id = 4;
            name = "antifa-n Alt-Tech";
            url = "https://raw.githubusercontent.com/antifa-n/pihole/master/blocklist-alttech.txt";
          }
          {
            enabled = true;
            id = 5;
            name = "antifa-n Pop";
            url = "https://raw.githubusercontent.com/antifa-n/pihole/master/blocklist-pop.txt";
          }
          {
            enabled = true;
            id = 6;
            name = "antifa-n Blocklist";
            url = "https://raw.githubusercontent.com/antifa-n/pihole/master/blocklist.txt";
          }
          {
            enabled = true;
            id = 7;
            name = "Tabloid Remover";
            url = "https://raw.githubusercontent.com/DandelionSprout/adfilt/refs/heads/master/Sensitive%20lists/TabloidRemover.txt";
          }
          {
            enabled = true;
            id = 8;
            name = "Fake Local Journals";
            url = "https://raw.githubusercontent.com/MassMove/AttackVectors/master/LocalJournals/fake-local-journals-list.txt";
          }
        ];
        querylog = {
          enabled = true;
          file_enabled = false;
          interval = "24h";
          size_memory = 1000;
        };
        statistics = {
          enabled = true;
          interval = "168h";
        };
        user_rules = [
          "@@||x.com^"
          "@@||twitter.com^"

          # TV Paramount allowlist
          "@@||pubads.g.doubleclick.net^$ctag=device_tv"
          "@@||googleads.g.doubleclick.net^$ctag=device_tv"
        ];
      };
    };
    resolved.enable = false;
  };
}
