{
  config,
  lib,
  pkgs,
  ...
}:
let
  baseStackFile = pkgs.writeText "komodo-stack-base.json" (
    builtins.toJSON {
      version = "3.8";
      services = {
        mongo = {
          image = "mongo:7";
          command = "--quiet --wiredTigerCacheSizeGB 0.25";
          volumes = [
            "mongo-data:/data/db"
            "mongo-config:/data/configdb"
          ];
          networks = [ "komodo" ];
          deploy = {
            mode = "replicated";
            replicas = 1;
            placement.constraints = [ "node.role == manager" ];
          };
        };
        core = {
          image = "ghcr.io/moghtech/komodo-core:latest";
          environment = {
            KOMODO_INIT_ADMIN_USERNAME = "walter";
            KOMODO_DATABASE_URI = "mongodb://mongo:27017";
            KOMODO_LOCAL_AUTH = "true";
          };
          volumes = [ "komodo-repo:/repo" ];
          networks = [ "komodo" ];
          ports = [
            {
              target = 9120;
              published = 9120;
              protocol = "tcp";
              mode = "host";
            }
          ];
          deploy = {
            mode = "replicated";
            replicas = 1;
            placement.constraints = [ "node.role == manager" ];
          };
        };
        periphery = {
          image = "ghcr.io/moghtech/komodo-periphery:latest";
          environment = {
            PERIPHERY_SSL_ENABLED = "false";
          };
          volumes = [
            "/var/run/docker.sock:/var/run/docker.sock"
            "/proc:/proc"
            "/etc/komodo:/etc/komodo"
          ];
          networks = [ "komodo" ];
          ports = [
            {
              target = 8120;
              published = 8120;
              protocol = "tcp";
              mode = "host";
            }
          ];
          deploy.mode = "global";
        };
      };
      networks.komodo = {
        driver = "overlay";
        attachable = true;
      };
      volumes = {
        mongo-data = { };
        mongo-config = { };
        komodo-repo = { };
      };
    }
  );
in
{
  networking.firewall.allowedTCPPorts = [
    9120 # Komodo UI
    8120 # Komodo Periphery
  ];
  systemd.services.komodo-stack = lib.mkIf (config.networking.hostName == "node-1") {
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
        ${baseStackFile} > "$TMPFILE"

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
