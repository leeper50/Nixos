{ config, pkgs, ... }:
{
  services.murmur = {
    bandwidth = 192000;
    enable = true;
    environmentFile = config.age.secrets."mumble_environment.age".path;
    logToFile = true;
    openFirewall = true;
    password = "$MURMUR_PASSWORD";
    registerHostname = "19280085.xyz";
    registerName = "DaBois";
    registerPassword = "$MURMUR_REGISTER_PASSWORD";
    registerUrl = "https://19280085.xyz";
    welcometext = "Merry Christmas!!";
  };

  systemd.services.murmur-superuser-password = {
    description = "Set Murmur SuperUser password";
    wantedBy = [ "multi-user.target" ];
    after = [ "murmur.service" ];
    requires = [ "murmur.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "murmur";
      Group = "murmur";
      LoadCredential = "supw:${config.age.secrets."mumble_superuser_password.age".path}";
      ExecStart = pkgs.writeShellScript "murmur-supw" ''
        ${config.services.murmur.package}/bin/mumble-server \
          -ini /run/murmur/murmurd.ini \
          -supw "$(cat "$CREDENTIALS_DIRECTORY/supw")"
      '';
    };
  };
}
