{
  config,
  globals,
  lib,
  osConfig ? null,
  pkgs,
  systemType,
  ...
}:
let
  cfg = config.local.packages;
  isStandalone = systemType == "Standalone";
  secretsAttrs = if osConfig != null then osConfig.age.secrets else (config.age.secrets or { });
  authTokenFile = secretsAttrs."surge_auth_token.age".path;
  configHome = if isStandalone then config.xdg.configHome else "/home/${globals.username}/.config";
  settingsFile = "${configHome}/surge/settings.toml";
  staticSettings = pkgs.writeText "surge-settings.toml" ''
    [network]
    proxy_url = "socks5://node-1.local:1080"
    [extension]
  '';
  writeSurgeSettings = pkgs.writeShellApplication {
    name = "write-surge-settings";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      mkdir -p "$(dirname "${settingsFile}")"

      token="$(tr -d '\n' <"${authTokenFile}")"

      tmp="$(mktemp "${settingsFile}.XXXXXX")"
      chmod 600 "$tmp"
      {
        cat "${staticSettings}"
        printf 'auth_token = "%s"\n' "$token"
      } >"$tmp"
      mv -f "$tmp" "${settingsFile}"
    '';
  };
  mkUserService =
    {
      description,
      serviceConfig,
      after ? [ ],
      requires ? [ ],
      wantedBy ? [ "default.target" ],
    }:
    if isStandalone then
      {
        Unit = {
          ConditionUser = globals.username;
          Description = description;
        }
        // lib.optionalAttrs (after != [ ]) { After = after; }
        // lib.optionalAttrs (requires != [ ]) { Requires = requires; };
        Service = serviceConfig;
        Install.WantedBy = wantedBy;
      }
    else
      {
        inherit
          after
          description
          requires
          serviceConfig
          wantedBy
          ;
        unitConfig.ConditionUser = globals.username;
      };
in
{
  options.local.packages.surge = {
    enable = lib.mkEnableOption "surge";
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.surge.enable {
      systemd.user.services = {
        surge-settings = mkUserService {
          description = "Render Surge settings.toml with the agenix auth token";
          after = lib.optionals isStandalone [ "agenix.service" ];
          requires = lib.optionals isStandalone [ "agenix.service" ];
          serviceConfig = {
            ExecStart = lib.getExe writeSurgeSettings;
            RemainAfterExit = true;
            Type = "oneshot";
          };
        };
        surge-server = mkUserService {
          description = "Surge Downloader Daemon";
          after = [
            "network.target"
            "surge-settings.service"
          ];
          requires = [ "surge-settings.service" ];
          serviceConfig = {
            ExecStart = "${pkgs.surge-downloader}/bin/surge server";
            Restart = "on-failure";
            RestartSec = 5;
            Type = "simple";
          };
        };
      };
    })
    (lib.mkIf (cfg.surge.enable) (
      if systemType == "Standalone" then
        {
          home.packages = [ pkgs.surge-downloader ];
        }
      else
        {
          environment.systemPackages = [ pkgs.surge-downloader ];
        }
    ))
  ];
}
