{ lib }:
{
  domain = "dellhp.party";
  fullName = "Walter Leeper";
  locale = "en_US.UTF-8";
  # `protocols` matches raw IP protocols that carry no port (VRRP, GRE, ...),
  # given as numbers or names.
  mkFirewallRules =
    {
      service,
      sources,
      protocols ? [ ],
      tcpPorts ? [ ],
      udpPorts ? [ ],
    }:
    let
      isV6 = source: lib.hasInfix ":" source;
      sourcesV4 = lib.filter (source: !isV6 source) sources;
      sourcesV6 = lib.filter isV6 sources;
      rule =
        family: familySources: match:
        lib.optionalString (familySources != [ ]) ''
          ${family} saddr { ${lib.concatStringsSep ", " familySources} } ${match} accept comment "${service}"
        '';
      portRules =
        family: familySources: protocol: ports:
        lib.optionalString (ports != [ ]) (
          rule family familySources "${protocol} dport { ${lib.concatMapStringsSep ", " toString ports} }"
        );
      protocolRules =
        family: familySources:
        lib.concatMapStrings (
          protocol: rule family familySources "meta l4proto ${toString protocol}"
        ) protocols;
    in
    {
      extraInputRules =
        portRules "ip " sourcesV4 "tcp" tcpPorts
        + portRules "ip " sourcesV4 "udp" udpPorts
        + protocolRules "ip " sourcesV4
        + portRules "ip6" sourcesV6 "tcp" tcpPorts
        + portRules "ip6" sourcesV6 "udp" udpPorts
        + protocolRules "ip6" sourcesV6;
    };
  networking = rec {
    docker = {
      ipv4Subnet = "172.30.0.0/16";
      ipv6Subnet = "fd06:6a55:3bd2:ed3d::/64";
      fixedv6Subnet = "fda3:db28:76bb:e314::/64";
    };
    hosts = {
      "19280085.xyz" = [
        "107.174.237.4"
      ];
      "buncha.men" = [
        "10.0.1.1"
        "2600:1702:58c1:9acf::1:1"
      ];
      "dellhp.party" = [
        "65.75.202.6"
        "2606:cc0:11:2351::1"
      ];
      "dellhplaptop.xyz" = [
        "10.0.1.1"
        "2600:1702:58c1:9acf::1:1"
      ];
      "komodo.local" = [
        "10.0.0.60"
        "2600:1702:58c1:9acf::60"
      ];
      "nas.local" = [
        "10.0.0.52"
        "2600:1702:58c1:9acf::52"
      ];
      "node-1.local" = [
        "10.0.0.21"
        "2600:1702:58c1:9acf::21"
      ];
      "node-2.local" = [
        "10.0.0.22"
        "2600:1702:58c1:9acf::22"
      ];
      "node-3.local" = [
        "10.0.0.23"
        "2600:1702:58c1:9acf::23"
      ];
      "tplinkwifi.net" = [
        "10.0.0.1"
        "2600:1702:58c1:9acf:f2a7:31ff:fe94:abac"
      ];
      "vpn.dellhplaptop.xyz" = [
        "10.0.0.60"
        "2600:1702:58c1:9acf::60"
      ];
    };
    ipv4 = {
      gateway = "10.0.0.1";
      lanSubnet = "10.0.0.0/8";
    };
    ipv6 = {
      gateway = "2600:1702:58c1:9acf:f2a7:31ff:fe94:abac";
      lanSubnet = "2600:1702:58c1:9acf::/64";
      linkLocalSubnet = "fe80::/10";
    };
    nameservers = {
      doh = [
        "https://dns.quad9.net/dns-query"
        "https://1.1.1.1/dns-query"
      ];
      local = [
        "10.0.1.1"
        "2600:1702:58c1:9acf::1:1"
      ];
      public = [
        "9.9.9.9"
        "149.112.112.112"
        "2620:fe::9"
        "2620:fe::fe"
      ];
    };
    swarmNodes = [
      "node-1.local"
      "node-2.local"
      "node-3.local"
    ];
    swarmAddresses = lib.concatMap (node: hosts.${node}) swarmNodes;
  };
  primaryEmail = "wleeper@mailbox.org";
  timeZone = "America/Chicago";
  username = "walter";
}
