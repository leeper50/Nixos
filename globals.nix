{
  domain = "19280085.xyz";
  fullName = "Walter Leeper";
  locale = "en_US.UTF-8";
  networking = {
    gatewayV4 = "10.0.0.1";
    gatewayV6 = "2600:1702:58c1:9acf:f2a7:31ff:fe94:abac";
    hosts = {
      "19280085.xyz" = [
        "65.75.202.6"
        "2606:cc0:11:2351::1"
      ];
      "buncha.men" = [
        "10.0.1.1"
        "2600:1702:58c1:9acf::1:1"
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
  };
  primaryEmail = "wleeper@mailbox.org";
  timeZone = "America/Chicago";
  username = "walter";
}
