{
  config,
  globals,
  lib,
  localLib,
  pkgs,
  ...
}:
let
  cfg = config.local.forgejo;
  pass = config.age.secrets;

  forgejoDomain = "git.${globals.domains.primary}";
  ports = {
    http = 3000;
    ssh = 2222;
  };
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
      age.secrets."postgresql_forgejo.age".file = ../../../secrets/postgresql_forgejo.age;
      networking.firewall = localLib.mkFirewallRules {
        service = "forgejo-ssh";
        sources = globals.networking.lan;
        tcpPorts = [ ports.ssh ];
      };
      services.forgejo = {
        database = {
          createDatabase = false;
          host = "nas.local";
          name = "forgejo";
          passwordFile = pass."postgresql_forgejo.age".path;
          type = "postgres";
          user = "forgejo";
        };
        enable = true;
        group = "forgejo";
        lfs.enable = true;
        package = pkgs.forgejo-lts;
        settings = {
          server = {
            DOMAIN = forgejoDomain;
            HTTP_ADDR = "127.0.0.1";
            HTTP_PORT = ports.http;
            ROOT_URL = "https://${forgejoDomain}/";
            SSH_LISTEN_PORT = ports.ssh;
            SSH_PORT = ports.ssh;
            START_SSH_SERVER = true;
          };
          session.COOKIE_SECURE = true;
        };
        stateDir = "/var/lib/forgejo";
        user = "forgejo";
      };
    })
    (lib.mkIf (cfg.server.enable && config.services.caddy.enable) {
      services.caddy.virtualHosts = localLib.mkCaddyVirtualHosts {
        git = "reverse_proxy 127.0.0.1:${toString ports.http}";
      };
    })
    (lib.mkIf cfg.runner.enable {
      age.secrets."forgejo_token.age" = {
        file = ../../../secrets/forgejo_token.age;
        group = "forgejo-runner-podman";
        owner = "forgejo-runner-podman";
      };
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
              url = "https://${forgejoDomain}/";
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
