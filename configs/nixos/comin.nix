{
  comin,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.local.comin;
  hostName = config.networking.hostName;
  tokenPath = config.age.secrets."ntfy_access_token.age".path;

  # Usage: notify <title> <priority> <tags> <message>
  # Ntfy notifier script
  notify = pkgs.writeShellScript "comin-ntfy-notify" ''
    printf 'header = "Authorization: Bearer %s"\n' "$(tr -d '[:space:]' < ${tokenPath})" |
      ${lib.getExe pkgs.curl} -fsS -K - \
        -H "Title: $1" -H "Priority: $2" -H "Tags: $3" \
        --data-binary "$4" \
        ${cfg.ntfy.url}/${cfg.ntfy.topic} > /dev/null
  '';

  # comin only runs postDeploymentCommand after a switch attempt, so this
  # catches failed activations but not eval/build failures.
  postDeploy = pkgs.writeShellScript "comin-post-deploy" ''
    [ "$COMIN_STATUS" = "done" ] && exit 0
    ${notify} "comin: ${hostName} deployment $COMIN_STATUS" high x \
      "$COMIN_GIT_REF ''${COMIN_GIT_SHA:0:8}: $COMIN_GIT_MSG
    $COMIN_ERROR_MSG"
  '';

  # Eval/build failures are only exposed via the exporter, so poll it and
  # notify on the 0 -> 1 transition of each failure gauge.
  checkMetrics = pkgs.writeShellScript "comin-ntfy-check" ''
    metrics=$(${lib.getExe pkgs.curl} -fsS http://127.0.0.1:${toString config.services.comin.exporter.port}/metrics) || exit 0
    for kind in eval build; do
      now=$(printf '%s\n' "$metrics" | ${lib.getExe pkgs.gawk} -v m="comin_last_''${kind}_failed" '$1 == m { print int($2) }')
      state="$STATE_DIRECTORY/$kind"
      prev=$(cat "$state" 2>/dev/null || echo 0)
      if [ "$now" = 1 ] && [ "$prev" != 1 ]; then
        ${notify} "comin: ${hostName} $kind failed" high x \
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
    ntfy = {
      enable = lib.mkEnableOption "ntfy notifications on comin failures" // {
        default = true;
      };
      url = lib.mkOption {
        type = lib.types.str;
        default = "https://n.dellhplaptop.xyz";
      };
      topic = lib.mkOption {
        type = lib.types.str;
        default = "Comin";
      };
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
            {
              name = "github";
              url = "https://github.com/leeper50/Nixos.git";
              branches.main.name = "main";
            }
          ];
        };
      }
      (lib.mkIf cfg.ntfy.enable {
        services.comin.postDeploymentCommand = postDeploy;
        systemd.services.comin-ntfy = {
          after = [ "comin.service" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = checkMetrics;
            StateDirectory = "comin-ntfy";
          };
        };
        systemd.timers.comin-ntfy = {
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
