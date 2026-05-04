{
  config,
  lib,
  pkgs,
  ...
}:
let
  baseStackFile = pkgs.writeText "portainer-stack-base.json" (
    builtins.toJSON {
      version = "3.2";
      services = {
        agent = {
          image = "portainer/agent:2.21.5";
          volumes = [
            "/var/run/docker.sock:/var/run/docker.sock"
            "/var/lib/docker/volumes:/var/lib/docker/volumes"
          ];
          networks = [ "agent_network" ];
          deploy = {
            mode = "global";
            placement.constraints = [ "node.platform.os == linux" ];
          };
        };
        portainer = {
          image = "portainer/portainer-ee:2.21.5";
          ports = [
            { target = 9000; published = 9000; protocol = "tcp"; mode = "host"; }
            { target = 9443; published = 9443; protocol = "tcp"; mode = "host"; }
            { target = 8000; published = 8000; protocol = "tcp"; mode = "host"; }
          ];
          volumes = [
            "/var/run/docker.sock:/var/run/docker.sock"
            "portainer_data:/data"
          ];
          networks = [ "agent_network" ];
          deploy = {
            mode = "replicated";
            replicas = 1;
            placement.constraints = [ "node.role == manager" ];
          };
        };
      };
      networks.agent_network = {
        driver = "overlay";
        attachable = true;
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

  systemd.services.portainer-stack = lib.mkIf (config.networking.hostName == "node-1") {
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
        '.services.portainer.command = "--license-key " + $key + " -H tcp://tasks.agent:9001"' \
        ${baseStackFile} > "$TMPFILE"

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
