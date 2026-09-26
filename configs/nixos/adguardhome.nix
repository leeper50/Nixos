# AdguardHome.yaml configuration - https://github.com/AdguardTeam/AdGuardHome/wiki/Configuration#configuration-file
{ globals, lib, ... }:
let
  logsSettings = {
    enabled = false;
    ignored = [
      "|dnstest.dellhplaptop.xyz^"
      "|.^"
    ];
    ignored_enabled = true;
    interval = "168h";
  };
  dns-lists = import ./lib/dns-lists.nix;
  filters = lib.imap1 (id: l: {
    enabled = true;
    inherit id;
    inherit (l) name;
    url = l.url.adguard or l.url;
  }) dns-lists.blocklists;
  allowRules = lib.concatMap (
    l:
    map (
      domain: "@@||${domain}^" + lib.optionalString (l.adguard.group != "") "$ctag=${l.adguard.group}"
    ) l.domains
  ) dns-lists.allowlists;
  ports = {
    dns = 53;
    webui = 3000;
  };
  dnsSources = [
    globals.networking.docker.fixedv6Subnet
    globals.networking.docker.ipv4Subnet
    globals.networking.docker.ipv6Subnet
    globals.networking.ipv4.lanSubnet
    globals.networking.ipv6.lanSubnet
  ];
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
    ) globals.networking.hosts
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
      ids = [ "10.0.0.167" ];
      name = "Bedroom TV 1";
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
  ];
in
{
  networking.firewall = globals.mkFirewallRules {
    service = "adguardhome";
    sources = dnsSources;
    tcpPorts = [ ports.dns ];
    udpPorts = [ ports.dns ];
  };
  services = {
    adguardhome = {
      enable = true;
      host = "0.0.0.0";
      mutableSettings = true;
      openFirewall = false;
      port = ports.webui;
      settings = {
        clients.persistent = map (c: defaultClientSettings // c) taggedClients;
        dns = {
          anonymize_client_ip = true;
          bind_hosts = [ "0.0.0.0" ];
          bootstrap_dns = globals.networking.nameservers.public;
          cache_enabled = true;
          cache_optimistic = true;
          cache_size = 4194304;
          hostsfile_enabled = false;
          port = ports.dns;
          ratelimit = 0;
          upstream_dns = globals.networking.nameservers.doh;
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
        inherit filters;
        querylog = logsSettings // {
          file_enabled = true;
          size_memory = 1000;
        };
        statistics = logsSettings;
        user_rules = allowRules;
      };
    };
    resolved.enable = false;
  };
}
