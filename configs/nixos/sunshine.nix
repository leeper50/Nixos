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
in
{
  options.local.sunshine = {
    enable = lib.mkEnableOption "Sunshine game streaming";
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
            global_prep_cmd = builtins.toJSON [
              {
                do = "${pkgs.systemd}/bin/systemctl --user start sunshine-inhibit.service";
                undo = "${pkgs.systemd}/bin/systemctl --user stop sunshine-inhibit.service";
              }
            ];
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
