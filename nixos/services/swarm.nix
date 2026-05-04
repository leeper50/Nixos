{ config, lib, pkgs, ... }:
{
  imports = [ ./docker.nix ];

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

  systemd.services.docker-swarm-init = lib.mkIf (config.networking.hostName == "node-1") {
    description = "Initialize Docker Swarm";
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      if ! ${pkgs.docker}/bin/docker info --format '{{.Swarm.LocalNodeState}}' | grep -q active; then
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
    # Token path is hardcoded rather than via config.age.secrets so this evaluates
    # cleanly before swarm_token.age has been created and rekeyed.
    script = ''
      TOKEN_FILE="/run/agenix/swarm_token.age"
      if [ ! -f "$TOKEN_FILE" ]; then
        echo "swarm_token.age not yet available — deploy after rekeying"
        exit 0
      fi
      if ! ${pkgs.docker}/bin/docker info --format '{{.Swarm.LocalNodeState}}' | grep -q active; then
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
