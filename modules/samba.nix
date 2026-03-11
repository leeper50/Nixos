{ config, ... }:
{
  # Samba configurations
  services.avahi = {
    allowInterfaces = [ "enp1s0" ];
    enable = true;
    nssmdns4 = true;
    nssmdns6 = false;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      workstation = true;
    };
  };
  services.samba-wsdd = {
    enable = true;
    interface = "enp1s0";
    openFirewall = true;
    workgroup = "WORKGROUP";
  };
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "hosts allow" = "10. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "min protocol" = "SMB2";
        "security" = "user";
        "server signing" = "auto";
        "server string" = "NixOS File Server";
        "smb3 unix extensions" = "yes";
        "workgroup" = "WORKGROUP";
      };
      media = {
        path = "/mnt/data/Media";
        browseable = "yes";
        writable = "yes";
        "create mask" = "0664";
        "directory mask" = "0775";
        "valid users" = "@users";
        "vfs objects" = "fruit streams_xattr";
        "fruit:encoding" = "native";
        "fruit:metadata" = "stream";
        "fruit:posix_rename" = "yes";
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
