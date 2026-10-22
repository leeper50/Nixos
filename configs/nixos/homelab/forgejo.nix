{
  config,
  globals,
  lib,
  localLib,
  pkgs,
  utils,
  secrets,
  ...
}:
let
  cfg = config.local.forgejo;
  pass = config.age.secrets;
  runnerUser = "forgejo-runner-podman";
  runnerUid = 399;
  httpAddr = "0.0.0.0";
  forgejoDomain = "fj.dellhplaptop.xyz";
  ports = {
    http = 3002;
    ssh = 2222;
  };
in
{
  options.local.forgejo = {
    runner = {
      enable = lib.mkEnableOption "forgejo runner";
      nixHost = lib.mkEnableOption ''
        a `nix:host` label that runs jobs directly on the host, using its nix
        daemon, store and network instead of a container
      '';
      token = lib.mkOption {
        type = lib.types.str;
        default = "";
      };
      uuid = lib.mkOption {
        type = lib.types.str;
        default = "";
      };
    };
    server.enable = lib.mkEnableOption "forgejo server";
  };
  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !(cfg.runner.enable && cfg.runner.uuid == "");
          message = "Must set local.forgejo.runner.uuid when using forgejo runner.";
        }
      ];
    }
    (lib.mkIf cfg.server.enable {
      age.secrets."forgejo_internal_token.age".file = "${secrets}/forgejo_internal_token.age";
      age.secrets."forgejo_lfs_jwt_secret.age".file = "${secrets}/forgejo_lfs_jwt_secret.age";
      age.secrets."forgejo_mailer_password.age".file = "${secrets}/forgejo_mailer_password.age";
      age.secrets."forgejo_secret_key.age".file = "${secrets}/forgejo_secret_key.age";
      age.secrets."postgresql_forgejo.age".file = "${secrets}/postgresql_forgejo.age";
      local.restic.backups.forgejo = {
        exclude = [
          "/var/lib/forgejo/data/queues"
          "/var/lib/forgejo/data/repo-archive"
          "/var/lib/forgejo/log"
        ];
        paths = [ "/var/lib/forgejo" ];
        user = "root";
      };
      networking.firewall = lib.mkMerge [
        (localLib.mkFirewallRules {
          service = "forgejo-ssh";
          sources = globals.networking.swarmAddresses;
          tcpPorts = [ ports.ssh ];
        })
        (localLib.mkFirewallRules {
          service = "forgejo-web";
          sources = [
            "0.0.0.0"
            "::/0"
          ];
          tcpPorts = [ ports.http ];
        })
      ];
      services.forgejo = {
        database = {
          createDatabase = false;
          host = globals.networking.hosts.nas.ipv4;
          name = "forgejo";
          passwordFile = pass."postgresql_forgejo.age".path;
          type = "postgres";
          user = "forgejo";
        };
        enable = true;
        group = "forgejo";
        lfs.enable = true;
        package = pkgs.forgejo;
        secrets = {
          mailer.PASSWD = pass."forgejo_mailer_password.age".path;
          security = {
            INTERNAL_TOKEN = lib.mkForce pass."forgejo_internal_token.age".path;
            SECRET_KEY = lib.mkForce pass."forgejo_secret_key.age".path;
          };
          server.LFS_JWT_SECRET = lib.mkForce pass."forgejo_lfs_jwt_secret.age".path;
        };
        settings = {
          DEFAULT = {
            APP_NAME = "Forgejo";
            APP_SLOGAN = "Beyond coding. We Forge.";
          };
          "cron.update_checker".ENABLED = false;
          database.SSL_MODE = "disable";
          mailer = {
            ENABLED = true;
            FROM = ''"Walter" <${globals.primaryEmail}>'';
            PROTOCOL = "smtp+starttls";
            SMTP_ADDR = "smtp.mailbox.org";
            SMTP_PORT = 587;
            SUBJECT_PREFIX = "[git] ";
            USER = globals.primaryEmail;
          };
          migrations.ALLOW_LOCALNETWORKS = true;
          "repository.pull-request".DEFAULT_MERGE_STYLE = "merge";
          "repository.signing".DEFAULT_TRUST_MODEL = "committer";
          security = {
            PASSWORD_HASH_ALGO = "pbkdf2_hi";
            REVERSE_PROXY_LIMIT = 1;
            REVERSE_PROXY_TRUSTED_PROXIES = lib.concatStringsSep "," globals.networking.swarmAddresses;
          };
          server = {
            BUILTIN_SSH_SERVER_USER = "git";
            DOMAIN = forgejoDomain;
            HTTP_ADDR = httpAddr;
            HTTP_PORT = ports.http;
            OFFLINE_MODE = true;
            ROOT_URL = "https://${forgejoDomain}/";
            SSH_DOMAIN = forgejoDomain;
            SSH_LISTEN_PORT = ports.ssh;
            SSH_PORT = ports.ssh;
            SSH_SERVER_USE_PROXY_PROTOCOL = true;
            START_SSH_SERVER = true;
          };
          service = {
            ALLOW_ONLY_EXTERNAL_REGISTRATION = false;
            DEFAULT_ALLOW_CREATE_ORGANIZATION = true;
            DEFAULT_ENABLE_TIMETRACKING = true;
            DEFAULT_KEEP_EMAIL_PRIVATE = false;
            DISABLE_REGISTRATION = true;
            ENABLE_CAPTCHA = false;
            ENABLE_NOTIFY_MAIL = true;
            NO_REPLY_ADDRESS = "noreply.localhost";
            REGISTER_EMAIL_CONFIRM = true;
            REQUIRE_SIGNIN_VIEW = false;
          };
          session = {
            COOKIE_SECURE = true;
            PROVIDER = "file";
          };
        };
        stateDir = "/var/lib/forgejo";
        user = "forgejo";
      };
      users = {
        groups.forgejo.gid = 398;
        users.forgejo.uid = 398;
      };
    })
    (lib.mkIf (cfg.server.enable && config.services.caddy.enable) {
      services.caddy.virtualHosts = localLib.mkCaddyVirtualHosts {
        fj = {
          extraConfig = "reverse_proxy ${httpAddr}:${toString ports.http}";
          ipFilter = null;
        };
      };
    })
    (lib.mkIf cfg.runner.enable {
      age.secrets."forgejo_token_${globals.hostName}.age" = {
        file = "${secrets}/forgejo_token_${globals.hostName}.age";
        group = runnerUser;
        owner = runnerUser;
      };
      virtualisation.docker.rootless = {
        enable = true;
        daemon.settings = {
          bip = lib.replaceStrings [ ".0/16" ] [ ".1/24" ] globals.networking.dockerRootless.ipv4Subnet;
          default-address-pools = [
            {
              base = globals.networking.dockerRootless.ipv4Subnet;
              size = 24;
            }
          ];
        };
      };
      systemd.user.services.docker.unitConfig.ConditionUser = lib.mkForce runnerUser;
      users = {
        groups.${runnerUser}.gid = runnerUid;
        users.${runnerUser} = {
          autoSubUidGidRange = true;
          createHome = true;
          group = runnerUser;
          home = "/var/lib/${runnerUser}";
          isSystemUser = true;
          linger = true;
          uid = runnerUid;
        };
      };
      services.forgejo-runner.instances."${config.networking.hostName}" = {
        enable = true;
        runtimes = {
          docker = lib.mkForce false;
          podman = lib.mkForce false;
        };
        settings = {
          container = {
            docker_host = "automount";
            # Nix needs namespaces for its build sandbox. Docker is rootless,
            # so "privileged" stays within the runner user's namespace.
            privileged = true;
          };
          runner.labels = [
            "docker:docker://data.forgejo.org/oci/node:20-bullseye"
            "ubuntu-latest:docker://docker.gitea.com/runner-images:ubuntu-latest"
            "ubuntu-22.04:docker://docker.gitea.com/runner-images:ubuntu-22.04"
            "ubuntu-20.04:docker://docker.gitea.com/runner-images:ubuntu-20.04"
          ]
          ++ lib.optional cfg.runner.nixHost "nix:host";
          server.connections = {
            default = {
              url = "https://${forgejoDomain}/";
              token_url = "file:${pass."forgejo_token_${globals.hostName}.age".path}";
              uuid = cfg.runner.uuid;
            };
          };
        };
      };
      # Must match the upstream unit name, which escapes the instance name
      # (node-2 -> node\x2d2); otherwise this defines a separate, unused unit.
      systemd.services."forgejo-runner-${utils.escapeSystemdPath config.networking.hostName}" =
        let
          uid = toString runnerUid;
        in
        {
          after = [ "user@${uid}.service" ];
          wants = [ "user@${uid}.service" ];
          environment.DOCKER_HOST = "unix:///run/user/${uid}/docker.sock";
          serviceConfig = {
            DynamicUser = lib.mkForce false;
            Group = runnerUser;
            User = runnerUser;
          };
        };
      systemd.tmpfiles.rules = [
        "d /var/lib/forgejo-runner/${config.networking.hostName} 0750 ${runnerUser} ${runnerUser} -"
      ];
    })
    (lib.mkIf (cfg.runner.enable && cfg.runner.nixHost) {
      services.forgejo-runner.instances."${config.networking.hostName}".hostPackages = with pkgs; [
        bash
        config.nix.package
        coreutils
        curl
        findutils
        gawk
        gnugrep
        gnused
        gnutar
        gzip
        nodejs
        openssh
        wget
      ];
      # CI builds now land in this host's store; collect garbage during a
      # build once free space drops below min-free, up to max-free.
      nix.settings = {
        max-free = 20 * 1024 * 1024 * 1024;
        min-free = 5 * 1024 * 1024 * 1024;
      };
    })
  ];
}
