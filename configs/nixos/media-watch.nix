{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.local.mediaWatch;
  watcher = pkgs.writeShellApplication {
    name = "media-watch";
    runtimeInputs = with pkgs; [
      curl
      inotify-tools
    ];
    text = ''
      refresh() {
        local key
        key=$(tr -d '[:space:]' < "$CREDENTIALS_DIRECTORY/api-key")
        curl --config <(printf 'header = "Authorization: MediaBrowser Token=\\"%s\\""\n' "$key") \
          --fail --max-time 30 --request POST --retry 3 --show-error --silent \
          "${cfg.jellyfinUrl}/Library/Refresh"
      }
      inotifywait --event close_write --event create --event delete \
        --event moved_from --event moved_to \
        --exclude '(\.part|\.!qB|\.tmp|~)$' \
        --format '%w%f' --monitor --quiet --recursive \
        ${lib.escapeShellArgs cfg.paths} |
        while read -r path; do
          while read -r -t ${toString cfg.debounce} drained; do path=$drained; done
          echo "changed: $path — refreshing Jellyfin libraries"
          refresh || echo "refresh failed"
        done
    '';
  };
in
{
  options.local.mediaWatch = {
    enable = lib.mkEnableOption "mediaWatch";
    debounce = lib.mkOption {
      default = 30;
      type = lib.types.int;
      description = ''
        Seconds of filesystem quiet to wait for before triggering a scan, so
        that a bulk import results in one refresh rather than hundreds.
      '';
    };
    jellyfinUrl = lib.mkOption {
      default = "https://jf.dellhplaptop.xyz";
      type = lib.types.str;
    };
    paths = lib.mkOption {
      default = [
        "/mnt/data/Media/Movies"
        "/mnt/data/Media/TV"
      ];
      type = lib.types.listOf lib.types.str;
      description = ''
        Send jellyfin library refresh when filesystem changes.
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    boot.kernel.sysctl = {
      "fs.inotify.max_user_instances" = 512;
      "fs.inotify.max_user_watches" = 524288;
    };
    systemd.services.media-watch = {
      after = [ "network-online.target" ];
      description = "Refresh Jellyfin libraries when media changes on disk";
      serviceConfig = {
        CapabilityBoundingSet = "";
        DynamicUser = true;
        ExecStart = lib.getExe watcher;
        LoadCredential = [
          "api-key:${config.age.secrets."jellyfin_api_key.age".path}"
        ];
        LockPersonality = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RequiresMountsFor = cfg.paths;
        Restart = "always";
        RestartSec = 10;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
        RestrictNamespaces = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [ "@system-service" ];
      };
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };
}
