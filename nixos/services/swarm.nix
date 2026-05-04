{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./docker.nix ];

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
      pkgs.util-linux
    ];
    script = ''
      apply_ipforward() {
        for netns in /run/docker/netns/*; do
          if [ -e "$netns" ]; then
            nsenter --net="/run/docker/netns/$netns" sysctl -w net.ipv4.ip_forward=1 2>/dev/null && \
              echo "Applied ip_forward to $netns" || \
              echo "Failed to apply to $netns"
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

  systemd.services.docker-swarm-init = lib.mkIf (config.networking.hostName == "node-1") {
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

  systemd.services.docker-swarm-join = lib.mkIf (config.networking.hostName != "node-1") {
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
          10.0.0.21:2377
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
}
