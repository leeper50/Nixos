{
  lib,
  hostName,
}:
let
  domains = rec {
    devicePrimary = "${hostName}.${primary}";
    deviceTailnet = "${hostName}.${tailnet}";
    primary = "dellhp.party";
    tailnet = "ts.${primary}";
  };
in
{
  inherit domains;
  fullName = "Walter Leeper";
  inherit hostName;
  locale = "en_US.UTF-8";
  networking = rec {
    dns = {
      "19280085.xyz" = [
        "107.174.237.4"
      ];
      "buncha.men" = [
        "10.0.1.1"
        "${ipv6.prefix}::1:1"
      ];
      "dellhplaptop.xyz" = [
        "10.0.1.1"
        "${ipv6.prefix}::1:1"
      ];
      "tplinkwifi.net" = [
        "10.0.0.1"
        "${ipv6.prefix}:f2a7:31ff:fe94:abac"
      ];
      "${domains.primary}" = [
        "65.75.202.6"
        "2606:cc0:11:2351::1"
      ];
    }
    // lib.mapAttrs' (
      n: v:
      lib.nameValuePair (n + ".${domains.primary}") (
        lib.filter (a: a != null) [
          v.ipv4
          v.ipv6
        ]
      )
    ) hosts;
    docker = {
      ipv4Subnet = "172.30.0.0/16";
      ipv6Subnet = "fd06:6a55:3bd2:ed3d::/64";
      fixedv6Subnet = "fda3:db28:76bb:e314::/64";
    };
    hosts = {
      laptop = {
        ipv4 = "10.0.0.71";
        ipv6 = "${ipv6.prefix}:73b7:bc38:4b1c:18ba";
      };
      nas = {
        ipv4 = "10.0.0.52";
        ipv6 = "${ipv6.prefix}::52";
      };
      node-1 = {
        ipv4 = "10.0.0.21";
        ipv6 = "${ipv6.prefix}::21";
      };
      node-2 = {
        ipv4 = "10.0.0.22";
        ipv6 = "${ipv6.prefix}::22";
      };
      node-3 = {
        ipv4 = "10.0.0.23";
        ipv6 = "${ipv6.prefix}::23";
      };
      racknerd = {
        ipv4 = "107.174.237.4";
        ipv6 = null;
      };
      servercheap = {
        ipv4 = "65.75.202.6";
        ipv6 = "2606:cc0:11:2351::1";
      };
    };
    ipv4 = rec {
      gateway = "10.0.0.1";
      lanSubnet = "10.0.0.0/${subnetMask}";
      subnetMask = "8";
    };
    ipv6 = rec {
      gateway = "${prefix}:f2a7:31ff:fe94:abac";
      lanSubnet = "${prefix}::/${subnetMask}";
      linkLocalSubnet = "fe80::/10";
      prefix = "2600:1702:58c1:9acf";
      subnetMask = "64";
    };
    lan = [
      ipv4.lanSubnet
      ipv6.lanSubnet
    ];
    nameservers = {
      doh = [
        "https://dns.quad9.net/dns-query"
        "https://1.1.1.1/dns-query"
      ];
      local = [
        "10.0.1.1"
        "${ipv6.prefix}::1:1"
      ];
      public = [
        "9.9.9.9"
        "149.112.112.112"
        "2620:fe::9"
        "2620:fe::fe"
      ];
    };
    tailnet = {
      laptop = {
        ipv4 = "100.64.0.9";
        ipv6 = "fd7a:115c:a1e0::9";
      };
      nas = {
        ipv4 = "100.64.0.8";
        ipv6 = "fd7a:115c:a1e0::8";
      };
      node-1 = {
        ipv4 = "100.64.0.5";
        ipv6 = "fd7a:115c:a1e0::5";
      };
      node-2 = {
        ipv4 = "100.64.0.6";
        ipv6 = "fd7a:115c:a1e0::6";
      };
      node-3 = {
        ipv4 = "100.64.0.7";
        ipv6 = "fd7a:115c:a1e0::7";
      };
      racknerd = {
        ipv4 = "100.64.0.3";
        ipv6 = "fd7a:115c:a1e0::3";
      };
      servercheap = {
        ipv4 = "100.64.0.2";
        ipv6 = "fd7a:115c:a1e0::2";
      };
    };
    swarmNodes = [
      "node-1"
      "node-2"
      "node-3"
    ];
    swarmAddresses = lib.concatMap (
      node:
      lib.filter (a: a != null) [
        hosts.${node}.ipv4
        hosts.${node}.ipv6
      ]
    ) swarmNodes;
  };
  primaryEmail = "wleeper@mailbox.org";
  sshPort = 34146;
  timeZone = "America/Chicago";
  username = "walter";
}
