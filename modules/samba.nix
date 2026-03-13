{ config, ... }:
{
  services.samba-wsdd = {
    enable = true;
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
        "min protocol" = "SMB3";
        "security" = "user";
        "server signing" = "auto";
        "server string" = "NixOS File Server";
        "smb encrypt" = "required";
        "smb3 unix extensions" = "yes";
        "workgroup" = "WORKGROUP";
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
        "vfs objects" = "fruit streams_xattr";
        "fruit:encoding" = "native";
        "fruit:metadata" = "stream";
        "fruit:posix_rename" = "yes";
      };
      homes = {
        comment = "Home directories";
        browseable = "no";
        writable = "yes";
        "create mask" = "0700";
        "directory mask" = "0700";
        "strict locking" = "no";
        "valid users" = "%S";
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
