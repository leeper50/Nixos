# Sunshine game streaming host for Moonlight clients.
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
  certDir = "/var/lib/sunshine-cert";
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
          applications.apps = [
            {
              name = "Desktop";
              image-path = "desktop.png";
            }
          ]
          ++ lib.optional config.programs.steam.enable (
            let
              setsid = "${pkgs.util-linux}/bin/setsid";
              steam = lib.getExe config.programs.steam.package;
            in
            {
              name = "Steam Big Picture";
              detached = [ "${setsid} ${steam} steam://open/bigpicture" ];
              image-path = "steam.png";
              prep-cmd = [
                {
                  do = "";
                  undo = "${setsid} ${steam} steam://close/bigpicture";
                }
              ];
            }
          );
          autoStart = true;
          # Required for KMS capture.
          capSysAdmin = true;
          enable = true;
          settings = {
            address_family = "both";
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
    (lib.mkIf (cfg.enable && config.services.caddy.enable) {
      services = {
        caddy.virtualHosts = localLib.mkCaddyVirtualHosts {
          sunshine = ''
            reverse_proxy https://127.0.0.1:47990 {
              transport http {
                tls_trust_pool file ${certDir}/cert.pem
              }
            }
          '';
        };
        sunshine.settings = {
          cert = "${certDir}/cert.pem";
          csrf_allowed_origins = "sunshine.${globals.domains.deviceTailnet}";
          pkey = "${certDir}/key.pem";
        };
      };
      # Generate valid cert for caddy & sunshine.
      systemd.services = {
        caddy = {
          after = [ "sunshine-cert.service" ];
          wants = [ "sunshine-cert.service" ];
        };
        sunshine-cert = {
          before = [ "display-manager.service" ];
          description = "Generate Sunshine's TLS certificate";
          path = [ pkgs.openssl ];
          script = ''
            if [ ! -s cert.pem ]; then
              openssl req -x509 -newkey rsa:2048 -nodes -days 7300 \
                -keyout key.pem -out cert.pem \
                -subj "/CN=Sunshine Gamestream Host" \
                -addext "subjectAltName=IP:127.0.0.1"
              chown ${cfg.user} key.pem
              chmod 600 key.pem
              chmod 644 cert.pem
            fi
          '';
          serviceConfig = {
            StateDirectory = "sunshine-cert";
            StateDirectoryMode = "0755";
            Type = "oneshot";
            UMask = "0077";
            WorkingDirectory = certDir;
          };
          wantedBy = [ "multi-user.target" ];
        };
      };
    })
  ];
}
