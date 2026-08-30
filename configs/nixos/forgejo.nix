{
  config,
  globals,
  lib,
  ...
}:
let
  cfg = config.local.forgejo;
  pass = config.age.secrets;
in
{
  options.local.forgejo = {
    runner = {
      enable = lib.mkEnableOption "forgejo runner";
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
      services.forgejo = {
        database.type = "sqlite3";
        enable = true;
        group = "forgejo";
        lfs.enable = true;
        settings = {
          server = {
            DOMAIN = "git.${globals.domain}";
            ROOT_URL = "https://${config.services.forgejo.settings.server.DOMAIN}:443/";
            SSH_PORT = 2222;
          };
          session.COOKIE_SECURE = true;
        };
        stateDir = "/var/lib/forgejo";
        user = "forgejo";
      };
    })
    (lib.mkIf (cfg.server.enable && config.services.nginx.enable) {
      services.nginx.virtualHosts."git.${globals.domain}" = {
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:3000";
        };
        useACMEHost = globals.domain;
      };
    })
    (lib.mkIf cfg.runner.enable {
      virtualisation.podman.enable = true;
      users = {
        groups.forgejo-runner-podman.gid = 399;
        users = {
          forgejo-runner-podman = {
            createHome = true;
            group = "forgejo-runner-podman";
            home = "/var/lib/forgejo-runner-podman";
            isSystemUser = true;
            linger = true;
            uid = 399;
          };
        };
      };
      services.forgejo-runner.instances."${config.networking.hostName}" = {
        enable = true;
        runtimes.podman = lib.mkForce false;
        settings = {
          runner.labels = [
            "docker:docker://data.forgejo.org/oci/node:20-bullseye"
            "ubuntu-latest:docker://docker.gitea.com/runner-images:ubuntu-latest"
            "ubuntu-22.04:docker://docker.gitea.com/runner-images:ubuntu-22.04"
            "ubuntu-20.04:docker://docker.gitea.com/runner-images:ubuntu-20.04"
          ];
          server.connections = {
            default = {
              url = "https://git.${globals.domain}/";
              token_url = "file:${pass."forgejo_token.age".path}";
              uuid = cfg.runner.uuid;
            };
          };
        };
      };
      systemd.services."forgejo-runner-${config.networking.hostName}" = {
        environment.DOCKER_HOST = "unix:///run/user/${toString config.users.users.forgejo-runner-podman.uid}/podman/podman.sock";
        serviceConfig = {
          DynamicUser = lib.mkForce false;
          Group = "forgejo-runner-podman";
          User = "forgejo-runner-podman";
        };
      };
    })
  ];
}
