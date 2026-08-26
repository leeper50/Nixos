{
  config,
  globals,
  lib,
  pkgs,
  osConfig ? null,
  ...
}:
let
  secretsAttrs = if osConfig != null then osConfig.age.secrets else (config.age.secrets or { });
  b2EnvFile = secretsAttrs."restic_b2_env.age".path;
  resticPasswordFile = secretsAttrs."restic_password_file.age".path;
  rustfsEnvFile = secretsAttrs."restic_rustfs_env.age".path;

  sftpSettings = {
    key_file = "~/.ssh/id_ed25519";
    known_hosts_file = "~/.ssh/known_hosts";
    md5sum_command = "md5sum";
    port = 22;
    sha1sum_command = "sha1sum";
    shell_type = "unix";
    type = "sftp";
    user = "root";
  };

  rcloneSecretsDir = "\${XDG_RUNTIME_DIR}/rclone-secrets";
  splitRcloneSecrets = pkgs.writeShellApplication {
    name = "split-rclone-secrets";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      outDir="''${XDG_RUNTIME_DIR:?XDG_RUNTIME_DIR not set}/rclone-secrets"
      install -d -m700 "$outDir"

      write_secret() {
        tmp="$(mktemp "$outDir/.$1.XXXXXX")"
        printf '%s' "$2" >"$tmp"
        chmod 600 "$tmp"
        mv -f "$tmp" "$outDir/$1"
      }
      (
        # shellcheck disable=SC1091
        source "${b2EnvFile}"
        write_secret b2-account "$B2_ACCOUNT_ID"
        write_secret b2-key "$B2_ACCOUNT_KEY"
        # shellcheck disable=SC1091
        source "${rustfsEnvFile}"
        write_secret rustfs-access-key "$RUSTFS_ACCESS_KEY"
        write_secret rustfs-secret-key "$RUSTFS_SECRET_KEY"
      )
    '';
  };
in
{
  programs.rclone = {
    enable = true;
    requiresUnit = "rclone-secrets.service";
    remotes = {
      Backblaze = {
        config = {
          type = "b2";
          hard_delete = true;
        };
        secrets = {
          account = "${rcloneSecretsDir}/b2-account";
          key = "${rcloneSecretsDir}/b2-key";
        };
      };
      Copyparty = {
        config = {
          type = "webdav";
          url = "https://c.dellhplaptop.xyz";
          vendor = "owncloud";
          pacer_min_sleep = "0.01ms";
          user = globals.username;
        };
        secrets.pass = resticPasswordFile;
      };
      Hetzner = {
        config = sftpSettings // {
          host = "u400147.your-storagebox.de";
          idle_timeout = 0;
          md5sum_command = "md5 -r";
          port = 23;
          sha1sum_command = "sha1 -r";
          user = "u400147";
        };
      };
      Komodo = {
        config = sftpSettings // {
          host = "komodo.local";
        };
      };
      Nas = {
        config = {
          type = "smb";
          host = "nas.local";
          port = 445;
          user = globals.username;
        };
        secrets.pass = secretsAttrs."user_${globals.username}_clear.age".path;
      };
      Node1 = {
        config = sftpSettings // {
          host = "node-1.local";
        };
      };
      Node2 = {
        config = sftpSettings // {
          host = "node-2.local";
        };
      };
      Node3 = {
        config = sftpSettings // {
          host = "node-3.local";
        };
      };
      RustFS = {
        config = {
          type = "s3";
          provider = "Other";
          endpoint = "http://nas.local:9000";
          region = "nas";
          force_path_style = true;
        };
        secrets = {
          access_key_id = "${rcloneSecretsDir}/rustfs-access-key";
          secret_access_key = "${rcloneSecretsDir}/rustfs-secret-key";
        };
      };
      Switch = {
        config = {
          type = "ftp";
          host = "10.0.0.170";
          user = globals.username;
          port = 5001;
          explicit_tls = true;
        };
        secrets.pass = resticPasswordFile;
      };
    };
  };
  systemd.user.services = {
    rclone-secrets = {
      Unit = {
        Description = "Split combined restic secret env files into individual rclone credential files";
      }
      // lib.optionalAttrs (osConfig == null) {
        Requires = [ "agenix.service" ];
        After = [ "agenix.service" ];
      };
      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = lib.getExe splitRcloneSecrets;
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}
