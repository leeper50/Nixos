{
  config,
  globals,
  lib,
  ...
}:
{
  config = lib.mkMerge [
    (lib.mkIf config.local.local {
      networking.firewall = globals.mkFirewallRules {
        service = "avahi";
        sources = [
          globals.networking.ipv4.lanSubnet
          globals.networking.ipv6.lanSubnet
          globals.networking.ipv6.linkLocalSubnet
        ];
        udpPorts = [ 5353 ];
      };
      services.avahi = {
        enable = true;
        nssmdns4 = true;
        nssmdns6 = true;
        openFirewall = false;
        publish = {
          addresses = true;
          domain = true;
          enable = true;
          workstation = true;
        };
        extraServiceFiles.timemachine = ''
          <?xml version="1.0" standalone='no'?>
          <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
          <service-group>
            <name replace-wildcards="yes">%h</name>
            <service>
              <type>_device-info._tcp</type>
              <port>0</port>
              <txt-record>model=TimeCapsule8,119</txt-record>
            </service>
            <service>
              <type>_adisk._tcp</type>
              <port>9</port>
              <txt-record>dk0=adVN=TimeMachine,adVF=0x82</txt-record>
              <txt-record>sys=waMA=0,adVF=0x100</txt-record>
            </service>
          </service-group>
        '';
      };
    })
  ];
}
