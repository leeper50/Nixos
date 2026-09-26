{
  config,
  globals,
  lib,
  ...
}:
let
  lanSources = [
    globals.networking.ipv4.lanSubnet
    globals.networking.ipv6.lanSubnet
  ];
  macSettings = {
    "fruit:encoding" = "native";
    "fruit:metadata" = "stream";
    "fruit:posix_rename" = "yes";
    "vfs objects" = "fruit streams_xattr";
  };
  timeMachineSettings = {
    "vfs objects" = "catia fruit streams_xattr";
    "fruit:time machine" = "yes";
    "durable handles" = "yes";
    "kernel oplocks" = "no";
    "kernel share modes" = "no";
    "posix locking" = "no";
  };
in
{
  networking.firewall = lib.mkMerge [
    (globals.mkFirewallRules {
      service = "samba";
      sources = lanSources;
      tcpPorts = [
        139 # NetBIOS session
        445 # SMB
      ];
      udpPorts = [
        137 # NetBIOS name service
        138 # NetBIOS datagram
      ];
    })
    (globals.mkFirewallRules {
      service = "samba-wsdd";
      sources = lanSources ++ [ globals.networking.ipv6.linkLocalSubnet ];
      tcpPorts = [ 5357 ]; # WSD transfer
      udpPorts = [ 3702 ]; # WS-Discovery
    })
  ];
  services.samba-wsdd = {
    enable = true;
    workgroup = "WORKGROUP";
  };
  services.samba = {
    enable = true;
    settings = {
      global = {
        "hosts allow" = "10. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "min protocol" = "SMB3";
        "security" = "user";
        "server signing" = "auto";
        "server string" = "NixOS File Server";
        "smb encrypt" = "required";
        "smb3 unix extensions" = "yes";
        "workgroup" = "WORKGROUP";
      };
      docker = {
        comment = "Docker volumes";
        path = "/mnt/docker";
        browseable = "yes";
        writable = "yes";
        "create mask" = "0664";
        "directory mask" = "0775";
        "strict locking" = "no";
        "valid users" = "@users";
      };
      Media = {
        comment = "Bulk media storage";
        path = "/mnt/data/Media";
        browseable = "yes";
        writable = "yes";
        "create mask" = "0664";
        "directory mask" = "0775";
        "strict locking" = "no";
        "valid users" = "@users";
      }
      // macSettings;
      homes = {
        comment = "Home directories";
        browseable = "no";
        writable = "yes";
        path = "/mnt/data/home/%S";
        "create mask" = "0700";
        "directory mask" = "0700";
        "strict locking" = "no";
        "valid users" = "%S";
      }
      // macSettings;
      TimeMachine = {
        comment = "Time Machine backups";
        path = "/mnt/data/TimeMachine";
        browseable = "yes";
        writable = "yes";
        "create mask" = "0600";
        "directory mask" = "0700";
        "strict locking" = "no";
        "valid users" = globals.username;
      }
      // timeMachineSettings;
    };
  };
  systemd = {
    services = lib.mkMerge [
      (lib.genAttrs (map (name: "samba-${name}") [
        "nmbd"
        "smbd"
        "winbindd"
      ]) (_: { unitConfig.RequiresMountsFor = [ "/mnt/data" ]; }))
      {
        samba-smbd.preStart = ''
          install -d -m 0700 -o ${globals.username} -g ${globals.username} /mnt/data/TimeMachine
        '';
        samba-smbd.postStart =
          let
            users = [ globals.username ];
            setupUser =
              user:
              let
                passwordPath = config.age.secrets."user_${user}_clear.age".path;
                smbpasswd = "${config.services.samba.package}/bin/smbpasswd";
              in
              ''
                (echo $(< ${passwordPath});
                 echo $(< ${passwordPath})) | \
                  ${smbpasswd} -s -a ${user}
              '';
          in
          ''
            ${builtins.concatStringsSep "\n" (map setupUser users)}
          '';
      }
    ];
  };
}
