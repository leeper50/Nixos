{
  config,
  lib,
  osConfig ? null,
  systemType,
  hostName ? null,
  ...
}:
let
  cfg = config.local.restic;
  isNixos = systemType == "Nixos";
  isStandalone = systemType == "Standalone";
  passwordFile =
    if osConfig != null then
      osConfig.age.secrets."user_walter_clear.age".path
    else
      config.age.secrets."user_walter_clear.age".path;
  resolvedHostName =
    if isStandalone then
      hostName
    else if osConfig != null then
      osConfig.networking.hostName
    else
      config.networking.hostName;
in
{
  options.local.restic = {
    backups = lib.mkOption {
      default = { };
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            exclude = lib.mkOption {
              default = [ ];
              type = lib.types.listOf lib.types.str;
            };
            location = lib.mkOption {
              default = "Systems/${resolvedHostName}";
              type = lib.types.str;
            };
            paths = lib.mkOption {
              default = [ ];
              type = lib.types.listOf lib.types.str;
            };
            user = lib.mkOption {
              default = "walter";
              type = lib.types.str;
            };
          };
        }
      );
    };
  };
  config = lib.mkMerge (
    lib.optionals isStandalone [
      {
        age.secretsDir = "/run/user/1000/agenix";
        services.restic.enable = true;
      }
    ]
    ++ [
      {
        services.restic.backups = lib.concatMapAttrs (
          name: backup:
          let
            common = {
              exclude = backup.exclude;
              extraOptions = [ "sftp.args='-i /home/walter/.ssh/id_ed25519'" ];
              initialize = true;
              passwordFile = passwordFile;
              paths = backup.paths;
              pruneOpts = [
                "--keep-daily 7"
                "--keep-weekly 4"
                "--keep-monthly 6"
              ];
              timerConfig = {
                OnCalendar = "00:05";
                RandomizedDelaySec = "5h";
              };
            }
            // lib.optionalAttrs isNixos { user = backup.user; };
          in
          {
            "${name}-nas" = common // {
              repository = "sftp:walter@10.0.0.33:/mnt/data/SambaHomes/walter/Backup/${backup.location}";
            };
            "${name}-hetzner" = common // {
              repository = "sftp:hetzner:/home/Backup/${backup.location}";
            };
          }
        ) cfg.backups;
      }
    ]
  );
}
