{ config, ... }:
{
  # Samba configurations
  services.avahi = {
    allowInterfaces = [ "enp1s0" ];
    enable = true;
    hostName = "server";
    nssmdns4 = true;
    nssmdns6 = false;
    openFirewall = true;
  };
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
  services.samba = {
    enable = true;
    nsswins = true;
    openFirewall = true;
    winbindd.enable = true;
    settings = {
      global = {
        "guest account" = "nobody";
        "hosts allow" = "10. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "map to guest" = "bad user";
        "netbios name" = "server";
        "security" = "user";
        "server string" = "server";
        "smb3 unix extensions" = "yes";
        "workgroup" = "WORKGROUP";
      };
      media = {
        path = "/mnt/data/Media";
        browseable = "yes";
        writable = "yes";
        "create mask" = "0664";
        "directory mask" = "0775";
        "force group" = "users";
      };
    };
  };
  # add user passwords
  systemd.services.samba-smbd.postStart =
    let
      users = [ "walter" ];
      setupUser =
        user:
        let
          passwordPath = config.age.secrets."user-${user}-clear.age".path;
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
