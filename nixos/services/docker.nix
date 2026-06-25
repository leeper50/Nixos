{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.local.docker;
in
{
  options.local.docker = {
    k3s.enable = lib.mkEnableOption "k3s";
    komodo.enable = lib.mkEnableOption "komodo";
    swarm = {
      enable = lib.mkEnableOption "swarm";
      manager = lib.mkEnableOption "swarm manager";
      managerIP = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
    };
    portainer.enable = lib.mkEnableOption "portainer";
  };
  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !cfg.swarm.enable || cfg.swarm.manager || cfg.swarm.managerIP != null;
          message = "local.docker.swarm.managerIP must be set when using swarm and swarm.manager is false.";
        }
      ];
    }

    ### Universal configuration
    {
      networking.nftables.enable = lib.mkForce false;
      virtualisation.docker = {
        enable = true;
        daemon.settings = {
          default-address-pools = [
            {
              base = "172.30.0.0/16";
              size = 24;
            }
            {
              base = "fd06:6a55:3bd2:ed3d::/64";
              size = 120;
            }
          ];
          experimental = true;
          fixed-cidr-v6 = "fda3:db28:76bb:e314::/64";
          ipv6 = true;
          ip6tables = true;
        };
        logDriver = "journald";
      };
      users.users.walter.extraGroups = [ "docker" ];
    }

    ### K3s configuration
    (lib.mkIf cfg.k3s.enable {
      boot.supportedFilesystems = [ "nfs" ];
      environment.systemPackages = with pkgs; [
        cifs-utils
        k3s
        nfs-utils
        openiscsi
      ];
      networking.firewall = {
        allowedTCPPorts = [
          # Flannel CNI
          8472 # VXLAN
          # iSCSI
          3260
          # K3s
          2379 # etcd client
          2380 # etcd peer
          6443 # k3s API server
          10250 # kubelet metrics
          10251 # k3s scheduler
          10252 # k3s controller manager
          # Metallb
          7946
        ];
        allowedUDPPorts = [
          # Flannel CNI
          8472 # VXLAN
          # Metallb
          7946
          # WireGuard
          51820
        ];
      };
      services.k3s = {
        clusterInit = cfg.swarm.manager;
        enable = true;
        extraFlags = toString (
          [
            "--disable local-storage"
            "--disable servicelb"
            "--disable traefik"
            "--write-kubeconfig-mode \"0644\""
          ]
          ++ (
            if cfg.swarm.manager then
              [ ]
            else
              [
                "--server https://${cfg.swarm.managerIP}:6443"
              ]
          )
        );
        role = "server";
        tokenFile = config.age.secrets."k3s_token.age".path;
      };
      services.openiscsi = {
        enable = true;
        name = "iqn.2020-08.org.linux-iscsi.${config.networking.hostName}.local:storage";
      };
      services.rpcbind.enable = true;
      systemd.tmpfiles.rules = [
        "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
      ];
      virtualisation.docker.logDriver = lib.mkForce "json-file";
    })

    ### Komodo configuration
    (lib.mkIf cfg.komodo.enable (
      let
        komodoStackFile = pkgs.writeText "komodo-stack-base.json" (
          builtins.toJSON {
            networks.komodo = {
              attachable = true;
              driver = "overlay";
            };
            services = {
              core = {
                deploy = {
                  mode = "replicated";
                  placement.constraints = [ "node.role == manager" ];
                  replicas = 1;
                };
                environment = {
                  KOMODO_DATABASE_URI = "mongodb://mongo:27017";
                  KOMODO_INIT_ADMIN_USERNAME = "walter";
                  KOMODO_LOCAL_AUTH = "true";
                };
                image = "ghcr.io/moghtech/komodo-core:2.2.0";
                networks = [ "komodo" ];
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
                command = "--quiet --wiredTigerCacheSizeGB 0.25";
                deploy = {
                  mode = "replicated";
                  placement.constraints = [ "node.role == manager" ];
                  replicas = 1;
                };
                image = "mongo:7";
                networks = [ "komodo" ];
                volumes = [
                  "mongo-config:/data/configdb"
                  "mongo-data:/data/db"
                ];
              };
              periphery = {
                deploy.mode = "global";
                environment = {
                  PERIPHERY_SSL_ENABLED = "true";
                };
                image = "ghcr.io/moghtech/komodo-periphery:2.2.0";
                networks = [ "komodo" ];
                ports = [
                  {
                    target = 8120;
                    published = 8120;
                    protocol = "tcp";
                    mode = "host";
                  }
                ];
                volumes = [
                  "/etc/komodo:/etc/komodo"
                  "/proc:/proc"
                  "/var/run/docker.sock:/var/run/docker.sock"
                  "komodo-keys:/config/keys"
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
        networking.firewall.allowedTCPPorts = [
          8120 # Komodo Periphery
          9120 # Komodo UI
        ];
        systemd.services.komodo-stack = {
          description = "Deploy Komodo stack";
          after = [ "docker-swarm-init.service" ];
          requires = [ "docker-swarm-init.service" ];
          wantedBy = [ "multi-user.target" ];
          script = ''
            ADMIN_PASS_FILE="/run/agenix/komodo_admin_password.age"

            if [ ! -f "$ADMIN_PASS_FILE" ]; then
              echo "komodo_admin_password.age not yet available — deploy after rekeying"
              exit 0
            fi

            TMPFILE="$(${pkgs.coreutils}/bin/mktemp)"
            trap "${pkgs.coreutils}/bin/rm -f $TMPFILE" EXIT

            ${pkgs.jq}/bin/jq \
              --arg admin_pass "$(cat "$ADMIN_PASS_FILE")" \
              '.services.core.environment.KOMODO_INIT_ADMIN_PASSWORD = $admin_pass' \
              ${komodoStackFile} > "$TMPFILE"

            ${pkgs.docker}/bin/docker stack deploy \
              --compose-file "$TMPFILE" \
              --detach \
              komodo
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

    ### Portainer configuration
    (lib.mkIf cfg.portainer.enable (
      let
        portainerStackFile = pkgs.writeText "portainer-stack-base.json" (
          builtins.toJSON {
            networks.agent_network = {
              attachable = true;
              driver = "overlay";
            };
            services = {
              agent = {
                deploy = {
                  mode = "global";
                  placement.constraints = [ "node.platform.os == linux" ];
                };
                image = "portainer/agent:2.39.1";
                networks = [ "agent_network" ];
                volumes = [
                  "/var/run/docker.sock:/var/run/docker.sock"
                  "/var/lib/docker/volumes:/var/lib/docker/volumes"
                ];
              };
              portainer = {
                deploy = {
                  mode = "replicated";
                  replicas = 1;
                  placement.constraints = [ "node.role == manager" ];
                };
                image = "portainer/portainer-ee:2.39.1";
                networks = [ "agent_network" ];
                ports = [
                  "9000:9000/tcp"
                  "9443:9443/tcp"
                  "8000:8000/tcp"
                ];
                volumes = [
                  "/var/run/docker.sock:/var/run/docker.sock"
                  "portainer_data:/data"
                ];
              };
            };
            volumes.portainer_data = { };
          }
        );
      in
      {
        networking.firewall.allowedTCPPorts = [
          9000 # Portainer HTTP
          9001 # Portainer agent
          9443 # Portainer HTTPS
        ];

        systemd.services.portainer-stack = {
          description = "Deploy Portainer stack";
          after = [ "docker-swarm-init.service" ];
          requires = [ "docker-swarm-init.service" ];
          wantedBy = [ "multi-user.target" ];
          script = ''
            LICENSE_FILE="/run/agenix/portainer_license.age"
            if [ ! -f "$LICENSE_FILE" ]; then
              echo "portainer_license.age not yet available — deploy after rekeying"
              exit 0
            fi

            TMPFILE="$(${pkgs.coreutils}/bin/mktemp)"
            trap "${pkgs.coreutils}/bin/rm -f $TMPFILE" EXIT

            ${pkgs.jq}/bin/jq \
              --arg key "$(cat "$LICENSE_FILE")" \
              '.services.portainer.command = "--license-key " + $key' \
              ${portainerStackFile} > "$TMPFILE"

            ${pkgs.docker}/bin/docker stack deploy \
              --compose-file "$TMPFILE" \
              --detach \
              portainer
          '';
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
      networking.firewall = {
        allowedTCPPorts = [
          2377 # swarm cluster management
          7946 # container network discovery
        ];
        allowedUDPPorts = [
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
              --advertise-addr 10.0.0.21 \
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
          TOKEN_FILE="/run/agenix/swarm_token.age"
          if [ ! -f "$TOKEN_FILE" ]; then
            echo "swarm_token.age not yet available — deploy after rekeying"
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
    })
  ];
}
