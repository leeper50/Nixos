{
  comin,
  config,
  globals,
  lib,
  pkgs,
  secrets,
  ...
}:
let
  cfg = config.local.comin;
  hostName = config.networking.hostName;
  tokenPath = config.age.secrets."gotify_comin_token.age".path;
  url = "https://g.dellhplaptop.xyz";

  # Usage: notify <title> <priority> <message>
  # Gotify notifier script; the token is the "comin" app's token.
  notify = pkgs.writeShellScript "comin-gotify-notify" ''
    printf 'header = "X-Gotify-Key: %s"\n' "$(tr -d '[:space:]' < ${tokenPath})" |
      ${lib.getExe pkgs.curl} -fsS -K - \
        --form-string "title=$1" --form-string "priority=$2" \
        --form-string "message=$3" \
        ${url}/message > /dev/null
  '';

  # comin's postBuildCommand: runs after every build and sends a low-priority
  # "build succeeded" notification with the commit. Failed builds also report
  # "built" (with COMIN_ERROR_MSG set), and unchanged hosts report
  # "already built"; both are skipped.
  postBuild = pkgs.writeShellScript "comin-post-build" ''
    [ "$COMIN_STATUS" = "built" ] && [ -z "$COMIN_ERROR_MSG" ] || exit 0
    ${notify} "comin: ${hostName} build succeeded" 2 \
      "$COMIN_GIT_REF ''${COMIN_GIT_SHA:0:8}: $COMIN_GIT_MSG"
  '';

  # comin's postDeploymentCommand: runs after every switch attempt and sends a
  # high-priority notification with the commit and error when the deployment
  # did not finish as "done". Eval/build failures never reach this point.
  postDeploy = pkgs.writeShellScript "comin-post-deploy" ''
    [ "$COMIN_STATUS" = "done" ] && exit 0
    ${notify} "comin: ${hostName} deployment $COMIN_STATUS" 8 \
      "$COMIN_GIT_REF ''${COMIN_GIT_SHA:0:8}: $COMIN_GIT_MSG
    $COMIN_ERROR_MSG"
  '';

  # Run by the comin-gotify timer every 5 minutes: reads the
  # comin_last_{eval,build}_failed gauges from comin's metrics exporter and
  # sends a high-priority notification when one goes from 0 to 1. The last
  # value is kept in $STATE_DIRECTORY so a failure is only reported once.
  checkMetrics = pkgs.writeShellScript "comin-gotify-check" ''
    metrics=$(${lib.getExe pkgs.curl} -fsS http://127.0.0.1:${toString config.services.comin.exporter.port}/metrics) || exit 0
    for kind in eval build; do
      now=$(printf '%s\n' "$metrics" | ${lib.getExe pkgs.gawk} -v m="comin_last_''${kind}_failed" '$1 == m { print int($2) }')
      state="$STATE_DIRECTORY/$kind"
      prev=$(cat "$state" 2>/dev/null || echo 0)
      if [ "$now" = 1 ] && [ "$prev" != 1 ]; then
        ${notify} "comin: ${hostName} $kind failed" 8 \
          "Last $kind failed. See: journalctl -u comin -b"
      fi
      echo "''${now:-0}" > "$state"
    done
  '';
in
{
  imports = [ comin.nixosModules.comin ];
  options.local.comin = {
    enable = lib.mkEnableOption "comin GitOps agent";
    gotify.enable = lib.mkEnableOption "gotify notifications on comin failures" // {
      default = true;
    };
  };
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        services.comin = {
          enable = true;
          remotes = [
            {
              name = "origin";
              url = "https://fj.dellhplaptop.xyz/wleeper13/Nixos.git";
              branches.main.name = "main";
            }
          ];
        };
        # The flake's `secrets` input is a private repo on Forgejo, fetched over
        # SSH by root with this host's SSH key (a read-only deploy key there).
        # Nix runs git to fetch it, which comin's unit doesn't provide.
        systemd.services.comin.path = [ pkgs.git ];
        programs.ssh = {
          extraConfig = ''
            Match host ${globals.forgejo.domain} localuser root
              IdentityFile /etc/ssh/ssh_host_ed25519_key
              IdentitiesOnly yes
          '';
          knownHosts.forgejo = {
            hostNames = [ "[${globals.forgejo.domain}]:${toString globals.forgejo.sshPort}" ];
            publicKey = globals.forgejo.sshHostKey;
          };
        };
      }
      (lib.mkIf cfg.gotify.enable {
        age.secrets."gotify_comin_token.age".file = "${secrets}/gotify_comin_token.age";
        services.comin = {
          postBuildCommand = postBuild;
          postDeploymentCommand = postDeploy;
        };
        systemd.services.comin-gotify = {
          after = [ "comin.service" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = checkMetrics;
            StateDirectory = "comin-gotify";
          };
        };
        systemd.timers.comin-gotify = {
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnBootSec = "5m";
            OnUnitActiveSec = "5m";
          };
        };
      })
    ]
  );
}
