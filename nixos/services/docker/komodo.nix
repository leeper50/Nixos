{
  config,
  lib,
  pkgs,
  ...
}:
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
