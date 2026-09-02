{
  config,
  globals,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.local.docker;
  komodo_version = "2.3.2";
in
{
  options.local.docker = {
    komodo = {
      core.enable = lib.mkEnableOption "core";
      coreIP = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      periphery.enable = lib.mkEnableOption "periphery";
    };
    remote = lib.mkEnableOption "remote";
    swarm = {
      enable = lib.mkEnableOption "swarm";
      labels = lib.mkOption {
        default = [ ];
        type = lib.types.listOf lib.types.str;
      };
      manager = lib.mkEnableOption "swarm manager";
      managerIP = lib.mkOption {
        default = null;
        type = lib.types.nullOr lib.types.str;
      };
    };
  };
  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !(!cfg.swarm.enable && cfg.swarm.manager);
          message = "local.docker.swarm.manager should not be true when not using swarm.";
        }
        {
          assertion = !(!cfg.swarm.enable && cfg.swarm.managerIP != null);
          message = "local.docker.swarm.managerIP should not be set when not using swarm.";
        }
        {
          assertion = !((cfg.komodo.core.enable || cfg.komodo.periphery.enable) && cfg.komodo.coreIP == null);
          message = "local.docker.komodo.coreIP must be set when using komodo.";
        }
        {
          assertion = !(!cfg.komodo.core.enable && !cfg.komodo.periphery.enable && cfg.komodo.coreIP != null);
          message = "local.docker.komodo.coreIP is set, but neither core or periphery are enabled.";
        }
      ];
    }

    ### Universal configuration
    {
      # Allow containers to reach 443 from host's private ip
      networking.firewall = globals.mkFirewallRules {
        service = "docker";
        sources = [
          globals.networking.docker.ipv4Subnet
          globals.networking.docker.ipv6Subnet
          globals.networking.docker.fixedv6Subnet
        ];
        tcpPorts = [ 443 ];
      };
      virtualisation.docker = {
        enable = true;
        daemon.settings = {
          default-address-pools = [
            {
              base = globals.networking.docker.ipv4Subnet;
              size = 24;
            }
            {
              base = globals.networking.docker.ipv6Subnet;
              size = 120;
            }
          ];
          dns =
            if cfg.remote then globals.networking.nameservers.public else globals.networking.nameservers.local;
          experimental = true;
          fixed-cidr-v6 = globals.networking.docker.fixedv6Subnet;
          ip6tables = true;
          ipv6 = true;
          labels = map (label: "${label}=true") cfg.swarm.labels;
        };
        logDriver = "journald";
      };
      users.users.${globals.username}.extraGroups = [ "docker" ];
    }

    ### Komodo periphery configuration
    (lib.mkIf cfg.komodo.periphery.enable (
      let
        komodoPeripheryStackFile = pkgs.writeText "komodo-periphery-stack-base.json" (
          builtins.toJSON {
            services.periphery = {
              environment = {
                PERIPHERY_CONNECT_AS = config.networking.hostName;
                PERIPHERY_CORE_ADDRESS = "ws://${cfg.komodo.coreIP}:9120";
                PERIPHERY_CORE_PUBLIC_KEYS = "MCowBQYDK2VuAyEAsxfy2FMcYn36sr7Sj/syAkaFxGIH6LKaOnYTF+578jo=";
                PERIPHERY_SSL_ENABLED = "true";
              };
              image = "ghcr.io/moghtech/komodo-periphery:${komodo_version}";
              ports = [ "8120:8120" ];
              volumes = [
                "/etc/komodo:/etc/komodo"
                "/proc:/proc"
                "/var/run/docker.sock:/var/run/docker.sock"
                "komodo-keys:/config/keys"
              ];
            };
            volumes.komodo-keys = { };
          }
        );
      in
      {
        systemd.services.komodo-periphery = {
          description = "Deploy Komodo periphery";
          after = [ "docker.service" ];
          requires = [ "docker.service" ];
          wantedBy = [ "multi-user.target" ];
          script = ''
            TMPFILE="$(${pkgs.coreutils}/bin/mktemp)"
            trap "${pkgs.coreutils}/bin/rm -f $TMPFILE" EXIT

            ONBOARDING_KEY_FILE="/run/agenix/komodo_onboarding_key.age"
            ONBOARDING_KEY="$([ -f "$ONBOARDING_KEY_FILE" ] && ${pkgs.coreutils}/bin/cat "$ONBOARDING_KEY_FILE" || true)"

            ${pkgs.jq}/bin/jq \
              --arg onboarding_key "$ONBOARDING_KEY" \
              'if $onboarding_key != "" then .services.periphery.environment.PERIPHERY_ONBOARDING_KEY = $onboarding_key else . end' \
              ${komodoPeripheryStackFile} > "$TMPFILE"

            ${pkgs.docker}/bin/docker compose -p komodo-periphery -f "$TMPFILE" up -d
          '';
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
        };
        systemd.tmpfiles.rules = [
          "d /etc/komodo 0777 root root -"
        ];
      }
    ))

    ### Komodo core configuration
    (lib.mkIf cfg.komodo.core.enable (
      let
        komodoCoreStackFile = pkgs.writeText "komodo-core-stack-base.json" (
          builtins.toJSON {
            networks.komodo = {
              attachable = true;
              driver = if cfg.swarm.enable then "overlay" else "bridge";
            };
            networks.proxy.external = true;
            services = {
              core = {
                deploy = lib.optionalAttrs cfg.swarm.enable {
                  labels = {
                    "homepage.group" = "Infrastructure";
                    "homepage.href" = "https://k.dellhplaptop.xyz";
                    "homepage.icon" = "sh-komodo.svg";
                    "homepage.name" = "Komodo";
                    "kuma.__docker" = "";
                    "release_notes" = "https://github.com/moghtech/komodo/releases";
                    "traefik.enable" = "true";
                    "traefik.http.routers.komodo.entryPoints" = "https";
                    "traefik.http.routers.komodo.middlewares" = "localonly@file";
                    "traefik.http.routers.komodo.rule" = "Host(`k.dellhplaptop.xyz`)";
                    "traefik.http.services.komodo.loadbalancer.server.port" = "9120";
                  };
                  mode = "replicated";
                  placement.constraints = [ "node.role == manager" ];
                  replicas = 1;
                };
                environment = {
                  KOMODO_DATABASE_URI = "mongodb://mongo:27017";
                  KOMODO_INIT_ADMIN_USERNAME = globals.username;
                  KOMODO_LOCAL_AUTH = "true";
                };
                image = "ghcr.io/moghtech/komodo-core:${komodo_version}";
                networks = [
                  "komodo"
                  "proxy"
                ];
                ports = [
                  {
                    mode = "host";
                    protocol = "tcp";
                    published = 9120;
                    target = 9120;
                  }
                ];
                volumes = [
                  "komodo-keys:/config/keys"
                  "komodo-repo:/repo-cache"
                ];
              };
              mongo = {
                deploy = lib.optionalAttrs cfg.swarm.enable {
                  mode = "replicated";
                  replicas = 1;
                  placement.constraints = [ "node.role == manager" ];
                };
                command = "--quiet --wiredTigerCacheSizeGB 0.25";
                image = "mongo:7";
                networks = [ "komodo" ];
                volumes = [
                  "mongo-config:/data/configdb"
                  "mongo-data:/data/db"
                ];
              };
            };
            volumes = {
              komodo-keys = { };
              komodo-repo = { };
              mongo-config = { };
              mongo-data = { };
            };
          }
        );
      in
      {
        systemd.services.komodo-core-stack = {
          description = "Deploy Komodo core stack";
          after = if cfg.swarm.enable then [ "docker-swarm-init.service" ] else [ "docker.service" ];
          requires = if cfg.swarm.enable then [ "docker-swarm-init.service" ] else [ "docker.service" ];
          wantedBy = [ "multi-user.target" ];
          script = ''
            TMPFILE="$(${pkgs.coreutils}/bin/mktemp)"
            trap "${pkgs.coreutils}/bin/rm -f $TMPFILE" EXIT

            ADMIN_PASS_FILE="/run/agenix/komodo_admin_password.age"
            if [ ! -f "$ADMIN_PASS_FILE" ]; then
              echo "komodo_admin_password.age not yet available — deploy after rekeying"
              exit 0
            fi

            ${pkgs.jq}/bin/jq \
              --arg admin_pass "$(cat "$ADMIN_PASS_FILE")" \
              '.services.core.environment.KOMODO_INIT_ADMIN_PASSWORD = $admin_pass' \
              ${komodoCoreStackFile} > "$TMPFILE"
          ''
          + (
            if cfg.swarm.enable then
              ''
                ${pkgs.docker}/bin/docker stack deploy \
                --compose-file "$TMPFILE" \
                --detach \
                komodo
              ''
            else
              ''
                ${pkgs.docker}/bin/docker compose -p komodo -f "$TMPFILE" up -d
              ''
          );
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
        };
      }
    ))

    ### Swarm configuration
    (lib.mkIf cfg.swarm.enable {
      boot.kernelModules = [
        "ip_vs"
        "ip_vs_rr"
        "ip_vs_wrr"
        "ip_vs_sh"
      ];
      networking.firewall = globals.mkFirewallRules {
        service = "docker-swarm";
        sources = globals.networking.swarmAddresses;
        tcpPorts = [
          2377 # swarm cluster management
          7946 # container network discovery
        ];
        udpPorts = [
          4789 # VXLAN overlay
          7946 # container network discovery
        ];
      };
      systemd.services.docker-netns-ipforward = {
        description = "Enable IP forwarding in Docker network namespaces";
        after = [ "docker.service" ];
        requires = [ "docker.service" ];
        wantedBy = [ "multi-user.target" ];
        path = [
          pkgs.inotify-tools
          pkgs.procps
          pkgs.util-linux
        ];
        script = ''
          apply_ipforward() {
            for netns in /run/docker/netns/*; do
              if [ -e "$netns" ]; then
                nsname=$(basename "$netns")
                nsenter --net="$netns" sysctl -w net.ipv4.ip_forward=1 2>/dev/null &&
                  echo "Applied ip_forward to $nsname" ||
                  echo "Failed to apply to $nsname"
              fi
            done
          }

          echo "Applying ip_forward to existing namespaces..."
          apply_ipforward

          echo "Monitoring for new namespaces..."
          while inotifywait -e create -e moved_to /run/docker/netns/ 2>/dev/null; do
            sleep 2
            apply_ipforward
          done
        '';
        serviceConfig = {
          Type = "simple";
          Restart = "always";
          RestartSec = 10;
        };
      };
      systemd.services.docker-swarm-init = lib.mkIf cfg.swarm.manager {
        description = "Initialize Docker Swarm";
        after = [ "docker.service" ];
        requires = [ "docker.service" ];
        wantedBy = [ "multi-user.target" ];
        script = ''
          if ! ${pkgs.docker}/bin/docker info --format '{{.Swarm.LocalNodeState}}' | grep -qx active; then
            ${pkgs.docker}/bin/docker swarm init \
              --advertise-addr ${cfg.swarm.managerIP} \
              --default-addr-pool 172.31.0.0/16 \
              --default-addr-pool-mask-length 24
          fi
        '';
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
      };
      systemd.services.docker-swarm-join = lib.mkIf (!cfg.swarm.manager) {
        description = "Join Docker Swarm";
        after = [
          "docker.service"
          "network-online.target"
        ];
        requires = [ "docker.service" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        script = ''
          TOKEN_FILE="/run/agenix/docker_swarm_token.age"
          if [ ! -f "$TOKEN_FILE" ]; then
            echo "docker_swarm_token.age not yet available — deploy after rekeying"
            exit 0
          fi
          if ! ${pkgs.docker}/bin/docker info --format '{{.Swarm.LocalNodeState}}' | grep -qx active; then
            ${pkgs.docker}/bin/docker swarm join \
              --token "$(cat "$TOKEN_FILE")" \
              ${cfg.swarm.managerIP}:2377
          fi
        '';
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
      };
      systemd.tmpfiles.rules = [
        "d /etc/docker 0775 ${globals.username} ${globals.username} -"
      ];
    })
  ];
}
