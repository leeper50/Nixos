{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.local.murmur;
  pass = config.age.secrets;
in
{
  options.local.murmur = {
    domain = lib.mkOption {
      default = "";
      type = lib.types.str;
    };
    enable = lib.mkEnableOption "Murmur - A mumble server";
    name = lib.mkOption {
      default = "";
      type = lib.types.str;
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      services.murmur = {
        bandwidth = 192000;
        enable = true;
        environmentFile = pass."murmur_environment.age".path;
        openFirewall = true;
        password = "$MURMUR_PASSWORD";
        registerHostname = cfg.domain;
        registerName = cfg.name;
        registerPassword = "$MURMUR_REGISTER_PASSWORD";
        registerUrl = "https://${cfg.domain}";
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
          LoadCredential = "supw:${pass."murmur_superuser_password.age".path}";
          ExecStart = pkgs.writeShellScript "murmur-supw" ''
            ${config.services.murmur.package}/bin/mumble-server \
              -ini /run/murmur/murmurd.ini \
              -supw "$(cat "$CREDENTIALS_DIRECTORY/supw")"
          '';
        };
      };
    })
  ];
}
