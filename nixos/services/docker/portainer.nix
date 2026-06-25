{
  config,
  lib,
  pkgs,
  ...
}:
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
