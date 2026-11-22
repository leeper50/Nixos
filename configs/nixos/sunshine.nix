# Sunshine game streaming host for Moonlight clients. Set the encoder and
# render device per host under services.sunshine.settings.
{
  config,
  globals,
  lib,
  localLib,
  pkgs,
  ...
}:
let
  cfg = config.local.sunshine;
  # Switch the output to the client's resolution and refresh rate for the
  # stream, adding a custom mode when the EDID lacks one, and restore the
  # previous mode afterwards. Uses Sunshine's SUNSHINE_CLIENT_* variables.
  matchClientMode = pkgs.writeShellApplication {
    name = "sunshine-match-client-mode";
    runtimeInputs = [
      pkgs.jq
      pkgs.kdePackages.libkscreen
    ];
    # The single-quoted $names are jq variables, not shell ones.
    excludeShellChecks = [ "SC2016" ];
    text = ''
      output=${lib.escapeShellArg cfg.output}
      state="$XDG_RUNTIME_DIR/sunshine-previous-mode"
      query() {
        kscreen-doctor -j | jq -er --arg o "$output" \
          --argjson w "''${SUNSHINE_CLIENT_WIDTH:-0}" \
          --argjson h "''${SUNSHINE_CLIENT_HEIGHT:-0}" \
          --argjson f "''${SUNSHINE_CLIENT_FPS:-0}" \
          ".outputs[] | select(.name == \$o) | $1"
      }
      find_mode() {
        query 'first(.modes[] | select(.size.width == $w and .size.height == $h
          and (.refreshRate | round) == $f) | .id)'
      }
      case "$1" in
        do)
          query .currentModeId > "$state"
          if ! id=$(find_mode); then
            kscreen-doctor "output.$output.addCustomMode.$SUNSHINE_CLIENT_WIDTH.$SUNSHINE_CLIENT_HEIGHT.$((SUNSHINE_CLIENT_FPS * 1000)).reduced"
            id=$(find_mode)
          fi
          kscreen-doctor "output.$output.mode.$id"
          ;;
        undo)
          if [ -s "$state" ]; then
            kscreen-doctor "output.$output.mode.$(cat "$state")"
          fi
          rm -f "$state"
          ;;
      esac
    '';
  };
in
{
  options.local.sunshine = {
    enable = lib.mkEnableOption "Sunshine game streaming";
    output = lib.mkOption {
      default = null;
      description = "Plasma output switched to the client's resolution during a stream.";
      example = "DP-1";
      type = lib.types.nullOr lib.types.str;
    };
    user = lib.mkOption {
      default = "walter";
      description = "User logged in automatically so Sunshine has a desktop to capture.";
      type = lib.types.str;
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      # LAN only; tailscale0 is already trusted for remote play.
      networking.firewall = localLib.mkFirewallRules {
        service = "sunshine";
        sources = globals.networking.lan.subnets;
        tcpPorts = [
          47984
          47989
          47990
          48010
        ];
        udpPorts = [
          47998
          47999
          48000
          48002
          48010
        ];
      };
      services = {
        # Sunshine runs in the user's graphical session.
        displayManager.autoLogin = {
          enable = true;
          inherit (cfg) user;
        };
        sunshine = {
          autoStart = true;
          # Required for KMS capture.
          capSysAdmin = true;
          enable = true;
          settings = {
            capture = lib.mkDefault "kms";
            # Plasma's idle timer ignores gamepads, so hold off sleep while a
            # stream runs. Released when the app is quit, not on disconnect.
            global_prep_cmd = builtins.toJSON (
              [
                {
                  do = "${pkgs.systemd}/bin/systemctl --user start sunshine-inhibit.service";
                  undo = "${pkgs.systemd}/bin/systemctl --user stop sunshine-inhibit.service";
                }
              ]
              ++ lib.optional (cfg.output != null) {
                do = "${lib.getExe matchClientMode} do";
                undo = "${lib.getExe matchClientMode} undo";
              }
            );
            sunshine_name = lib.mkDefault config.networking.hostName;
          };
        };
      };
      systemd.user.services.sunshine-inhibit = {
        description = "Block sleep during a Sunshine stream";
        serviceConfig.ExecStart = "${pkgs.systemd}/bin/systemd-inhibit --what=idle:sleep --who=Sunshine --why=Streaming ${pkgs.coreutils}/bin/sleep infinity";
      };
    })
  ];
}
