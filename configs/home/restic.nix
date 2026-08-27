{
  config,
  globals,
  hostName ? null,
  lib,
  osConfig ? null,
  systemType,
  ...
}:
let
  cfg = config.local.restic;
  extraOptionsAttrs = {
    "${globals.username}" = [ "sftp.args='-i /home/${globals.username}/.ssh/id_ed25519'" ];
    "root" = [ "sftp.args='-i /etc/ssh/ssh_host_ed25519_key'" ];
  };
  isNixos = systemType == "Nixos";
  isStandalone = systemType == "Standalone";
  secretsAttrs = if osConfig != null then osConfig.age.secrets else config.age.secrets;
  b2EnvironmentFile = secretsAttrs."restic_b2_env.age".path;
  passwordFile = secretsAttrs."restic_password_file.age".path;
  rustfsEnvironmentFile = secretsAttrs."restic_rustfs_env.age".path;
  targetGenerators = {
    b2 =
      {
        name,
        common,
        location,
      }:
      {
        "${name}-b2" = common // {
          environmentFile = b2EnvironmentFile;
          pruneOpts = [ ];
          repository = "b2:dhp-backups:${location}";
          runCheck = false;
        };
        "${name}-b2-prune" = common // {
          environmentFile = b2EnvironmentFile;
          paths = [ ];
          repository = "b2:dhp-backups:${location}";
          timerConfig.OnCalendar = "Sun *-*-* 13:00:00"; # weekly
        };
      };
    hetzner =
      {
        name,
        common,
        location,
      }:
      {
        "${name}-hetzner" = common // {
          repository = "sftp://u400147@u400147.your-storagebox.de:23//home/Backup/${location}";
        };
      };
    nas =
      {
        name,
        common,
        location,
      }:
      {
        "${name}-nas" = common // {
          environmentFile = rustfsEnvironmentFile;
          repository = "s3:http://nas.local:9000/dhp-backups/${location}";
        };
      };
  };
  targetNames = lib.attrNames targetGenerators;
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
            paths = lib.mkOption {
              default = [ ];
              type = lib.types.listOf lib.types.str;
            };
            targets = lib.mkOption {
              default = targetNames;
              type = lib.types.listOf (lib.types.enum targetNames);
              description = "Backup targets this share should back up to. Defaults to all targets; hosts can restrict to a subset.";
            };
            user = lib.mkOption {
              default = globals.username;
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
    ++ lib.optionals isNixos [
      {
        programs.ssh.knownHosts = {
          "[u400147.your-storagebox.de]:23".publicKey =
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICf9svRenC/PLKIL9nk6K/pxQgoiFC41wTNvoIncOxs";
        };
      }
    ]
    ++ [
      {
        services.restic.backups = lib.concatMapAttrs (
          name: backup:
          let
            common = {
              exclude = backup.exclude;
              extraBackupArgs = [
                "--pack-size"
                "64"
              ];
              extraOptions = if extraOptionsAttrs ? ${backup.user} then extraOptionsAttrs.${backup.user} else [ ];
              initialize = true;
              passwordFile = passwordFile;
              paths = backup.paths;
              pruneOpts = [
                "--keep-daily 7"
              ];
              timerConfig.OnCalendar = "*-*-* 13:00:00"; # 1pm Daily
            }
            // lib.optionalAttrs isNixos { user = backup.user; };
            location = resolvedHostName + "/" + name;
          in
          lib.mergeAttrsList (
            map (target: targetGenerators.${target} { inherit name common location; }) backup.targets
          )
        ) cfg.backups;
      }
    ]
  );
}
