{
  # Samba configurations
  services.avahi.enable = true;
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
  services.samba = {
    enable = true;
    enableNmbd = false;
    enableWinbindd = false;
    securityType = "user";
    openFirewall = true;
    settings = {
      global = {
        "smb3 unix estensions" = "yes";
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
    extraConfig = ''
      workgroup = WORKGROUP
      server string = smbnix
      netbios name = smbnix
      map to guest = bad user
    '';
  };
  # add user passwords
  systemd.services.samba-smbd.postStart =
  let
    users = [ "walter" ];
    setupUser = user: let
      passwordPath = config.age.secrets."user-${user}-clear.age".path;
      smbpasswd = "${config.services.samba.package}/bin/smbpasswd";
    in ''
      (echo $(< ${passwordPath});
       echo $(< ${passwordPath})) | \
        ${smbpasswd} -s -a ${user}
    '';
  in
  ''
    ${builtins.concatStringsSep "\n" (map setupUser users)}
  '';
}