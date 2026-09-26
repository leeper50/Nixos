{
  allowlists = [
    {
      adguard.group = "";
      category = "farRight";
      domains = [
        "x.com"
        "twitter.com"
      ];
      name = "Twitter";
    }
    {
      adguard.group = "device_tv";
      category = "ads";
      domains = [
        "googleads.g.doubleclick.net"
        "pubads.g.doubleclick.net"
      ];
      name = "Paramount Allowlists";
    }
  ];
  blocklists = [
    {
      category = "ads";
      name = "HaGeZi multi pro";
      source = "https://github.com/hagezi/dns-blocklists#pro";
      url = {
        adguard = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/pro.txt";
        blocky = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/pro.txt";
      };
    }
    {
      category = "disinformation";
      name = "Tabloids";
      source = "https://github.com/DandelionSprout/adfilt/tree/master/Sensitive%20lists";
      url = "https://raw.githubusercontent.com/DandelionSprout/adfilt/refs/heads/master/Sensitive%20lists/TabloidRemover.txt";
    }
    {
      category = "farRight";
      name = "Alt tech platforms";
      source = "https://github.com/antifa-n/pihole";
      url = "https://raw.githubusercontent.com/antifa-n/pihole/master/blocklist-alttech.txt";
    }
    {
      category = "farRight";
      name = "Populist";
      source = "https://github.com/antifa-n/pihole";
      url = "https://raw.githubusercontent.com/antifa-n/pihole/master/blocklist-pop.txt";
    }
    {
      category = "farRight";
      name = "Ethno nationalists";
      source = "https://github.com/antifa-n/pihole";
      url = "https://raw.githubusercontent.com/antifa-n/pihole/master/blocklist.txt";
    }
  ];
}