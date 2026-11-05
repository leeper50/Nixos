{
  config,
  globals,
  lib,
  localLib,
  pkgs,
  secrets,
  ...
}:
let
  komodo_version = "2.3.4";
  swarmNetworks = {
    proxy = true;
    socket-proxy = false;
  };
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
          assertion = !(!config.local.docker.swarm.enable && config.local.docker.swarm.manager);
          message = "local.docker.swarm.manager should not be true when not using swarm.";
        }
        {
          assertion = !(!config.local.docker.swarm.enable && config.local.docker.swarm.managerIP != null);
          message = "local.docker.swarm.managerIP should not be set when not using swarm.";
        }
        {
          assertion =
            !(
              (config.local.docker.komodo.core.enable || config.local.docker.komodo.periphery.enable)
              && config.local.docker.komodo.coreIP == null
            );
          message = "local.docker.komodo.coreIP must be set when using komodo.";
        }
        {
          assertion =
            !(
              !config.local.docker.komodo.core.enable
              && !config.local.docker.komodo.periphery.enable
              && config.local.docker.komodo.coreIP != null
            );
          message = "local.docker.komodo.coreIP is set, but neither core or periphery are enabled.";
        }
      ];
    }

    ### Universal configuration
    {
      # Allow containers to reach 443 from host's private ip
      networking.firewall = localLib.mkFirewallRules {
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
            if config.local.local then
              globals.networking.nameservers.local
            else
              globals.networking.nameservers.public;
          experimental = true;
          fixed-cidr-v6 = globals.networking.docker.fixedv6Subnet;
          ip6tables = true;
          ipv6 = true;
          labels = map (label: "${label}=true") config.local.docker.swarm.labels;
        };
        logDriver = "journald";
      };
      # dockerd starts every container at once, so one that shares another
      # container's network fails with "cannot join network namespace" if
      # it beats that container, and dockerd never retries it.
      # Start those once their network is running.
      systemd.services.docker-netns-dependents = {
        description = "Start containers that failed to join another container's network";
        after = [ "docker.service" ];
        bindsTo = [ "docker.service" ];
        wantedBy = [
          "docker.service"
          "multi-user.target"
        ];
        path = [ pkgs.docker ];
        script = ''
          for _ in $(seq 60); do
            waiting=0
            for id in $(docker ps -aq --filter status=exited --filter status=created); do
              state=$(docker inspect --format '{{.HostConfig.NetworkMode}}|{{.State.Error}}' "$id") || continue
              case "$state" in
                container:*"|"*"cannot join network namespace"*) ;;
                *) continue ;;
              esac
              target=''${state%%|*}
              target=''${target#container:}
              if [ "$(docker inspect --format '{{.State.Running}}' "$target" 2>/dev/null)" = true ]; then
                docker start "$id" >/dev/null && echo "Started $(docker inspect --format '{{.Name}}' "$id")"
              else
                waiting=1
              fi
            done
            [ "$waiting" = 0 ] && exit 0
            sleep 5
          done
          echo "Gave up: some containers' network containers never started" >&2
          exit 1
        '';
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
      };
      users.users.walter.extraGroups = [ "docker" ];
    }

    ### Komodo periphery configuration
    (lib.mkIf config.local.docker.komodo.periphery.enable (
      let
        komodoPeripheryStackFile = pkgs.writeText "komodo-periphery-stack-base.json" (
          builtins.toJSON {
            services.periphery = {
              environment = {
                PERIPHERY_CONNECT_AS = config.networking.hostName;
                PERIPHERY_CORE_ADDRESS = "ws://${config.local.docker.komodo.coreIP}:9120";
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
        age.secrets."komodo_onboarding_key.age".file = "${secrets}/komodo_onboarding_key.age";
        systemd.services.komodo-periphery = {
          description = "Deploy Komodo periphery";
          after = [ "docker.service" ];
          requires = [ "docker.service" ];
          wantedBy = [ "multi-user.target" ];
          script = ''
            TMPFILE="$(${pkgs.coreutils}/bin/mktemp)"
            trap "${pkgs.coreutils}/bin/rm -f $TMPFILE" EXIT

            ONBOARDING_KEY_FILE="${config.age.secrets."komodo_onboarding_key.age".path}"
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
    (lib.mkIf config.local.docker.komodo.core.enable (
      let
        komodoCoreStackFile = pkgs.writeText "komodo-core-stack-base.json" (
          builtins.toJSON {
            networks.komodo = {
              attachable = true;
              driver = if config.local.docker.swarm.enable then "overlay" else "bridge";
            };
            networks.proxy.external = true;
            services = {
              core = {
                deploy = lib.optionalAttrs config.local.docker.swarm.enable {
                  labels = {
                    "homepage.group" = "Infrastructure";
                    "homepage.href" = "https://k.dellhplaptop.xyz";
                    "homepage.icon" = "sh-komodo.svg";
                    "homepage.name" = "Komodo";
                    "kuma.__docker" = "";
                    "release_notes" = "https://github.com/moghtech/komodo/releases";
                    "traefik.enable" = "true";
                    "traefik.http.routers.komodo-webhooks.entryPoints" = "https";
                    "traefik.http.routers.komodo-webhooks.middlewares" = "webhooks@file";
                    "traefik.http.routers.komodo-webhooks.rule" =
                      "Host(`k.dellhplaptop.xyz`) && PathPrefix(`/listener/`)";
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
                  KOMODO_HOST = "https://k.dellhplaptop.xyz";
                  KOMODO_INIT_ADMIN_USERNAME = "walter";
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
                deploy = lib.optionalAttrs config.local.docker.swarm.enable {
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
        age.secrets."komodo_admin_password.age".file = "${secrets}/komodo_admin_password.age";
        systemd.services.komodo-core-stack = {
          description = "Deploy Komodo core stack";
          after =
            if config.local.docker.swarm.enable then
              [ "docker-swarm-networks.service" ]
            else
              [ "docker.service" ];
          requires =
            if config.local.docker.swarm.enable then
              [ "docker-swarm-networks.service" ]
            else
              [ "docker.service" ];
          wantedBy = [ "multi-user.target" ];
          script = ''
            TMPFILE="$(${pkgs.coreutils}/bin/mktemp)"
            trap "${pkgs.coreutils}/bin/rm -f $TMPFILE" EXIT

            ADMIN_PASS_FILE="${config.age.secrets."komodo_admin_password.age".path}"
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
            if config.local.docker.swarm.enable then
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
    (lib.mkIf config.local.docker.swarm.enable {
      boot.kernelModules = [
        "ip_vs"
        "ip_vs_rr"
        "ip_vs_wrr"
        "ip_vs_sh"
      ];
      networking.firewall = localLib.mkFirewallRules {
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
      systemd.services.docker-gwbridge = {
        description = "Create docker_gwbridge with IPv6";
        after = [ "docker.service" ];
        requires = [ "docker.service" ];
        before = [
          "docker-swarm-init.service"
          "docker-swarm-join.service"
        ];
        requiredBy = [
          (
            if config.local.docker.swarm.manager then
              "docker-swarm-init.service"
            else
              "docker-swarm-join.service"
          )
        ];
        wantedBy = [ "multi-user.target" ];
        script = ''
          if ! ${pkgs.docker}/bin/docker network inspect docker_gwbridge >/dev/null 2>&1; then
            ${pkgs.docker}/bin/docker network create \
              --ipv6 \
              --opt com.docker.network.bridge.name=docker_gwbridge \
              --opt com.docker.network.bridge.enable_icc=false \
              --opt com.docker.network.bridge.enable_ip_masquerade=true \
              docker_gwbridge
          elif [ "$(${pkgs.docker}/bin/docker network inspect docker_gwbridge --format '{{.EnableIPv6}}')" != true ]; then
            echo "WARNING: docker_gwbridge has no IPv6; IPv6 clients of published swarm ports lose their source address" >&2
          fi
        '';
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
      };
      systemd.services.docker-swarm-networks = lib.mkIf config.local.docker.swarm.manager {
        description = "Create shared Docker Swarm networks";
        after = [ "docker-swarm-init.service" ];
        requires = [ "docker-swarm-init.service" ];
        wantedBy = [ "multi-user.target" ];
        script = lib.concatStrings (
          lib.mapAttrsToList (name: attachable: ''
            if ! ${pkgs.docker}/bin/docker network inspect ${name} >/dev/null 2>&1; then
              ${pkgs.docker}/bin/docker network create --driver overlay ${lib.optionalString attachable "--attachable"} ${name}
            fi
          '') swarmNetworks
        );
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
      };
      systemd.services.docker-swarm-init = lib.mkIf config.local.docker.swarm.manager {
        description = "Initialize Docker Swarm";
        after = [ "docker.service" ];
        requires = [ "docker.service" ];
        wantedBy = [ "multi-user.target" ];
        script = ''
          if ! ${pkgs.docker}/bin/docker info --format '{{.Swarm.LocalNodeState}}' | ${pkgs.ripgrep}/bin/rg -qx active; then
            ${pkgs.docker}/bin/docker swarm init \
              --advertise-addr ${config.local.docker.swarm.managerIP} \
              --default-addr-pool 172.31.0.0/16 \
              --default-addr-pool-mask-length 24
          fi
        '';
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
      };
      age.secrets."docker_swarm_token.age" = lib.mkIf (!config.local.docker.swarm.manager) {
        file = "${secrets}/docker_swarm_token.age";
      };
      systemd.services.docker-swarm-join = lib.mkIf (!config.local.docker.swarm.manager) {
        description = "Join Docker Swarm";
        after = [
          "docker.service"
          "network-online.target"
        ];
        requires = [ "docker.service" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        script = ''
          TOKEN_FILE="${config.age.secrets."docker_swarm_token.age".path}"
          if [ ! -f "$TOKEN_FILE" ]; then
            echo "docker_swarm_token.age not yet available — deploy after rekeying"
            exit 0
          fi
          if ! ${pkgs.docker}/bin/docker info --format '{{.Swarm.LocalNodeState}}' | ${pkgs.ripgrep}/bin/rg -qx active; then
            ${pkgs.docker}/bin/docker swarm join \
              --token "$(cat "$TOKEN_FILE")" \
              ${config.local.docker.swarm.managerIP}:2377
          fi
        '';
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
      };
      systemd.tmpfiles.rules = [
        "d /etc/docker 0775 walter walter -"
      ];
    })
  ];
}
