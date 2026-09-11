{
  config,
  lib,
  pkgs,
  ...
}:
let
  cycle-audio-output = import ./cycle-audio-output.nix { inherit pkgs; };
  mod = config.wayland.windowManager.sway.config.modifier;
  noctalia = "exec noctalia msg";
in
{
  home.packages = [
    pkgs.autotiling-rs
  ];
  stylix.targets.sway = {
    enable = true;
    useWallpaper = false;
  };
  wayland.windowManager.sway = {
    enable = true;
    package = null;
    systemd.extraCommands = [
      "systemctl --user reset-failed"
      "systemctl --user start sway-session.target"
      "swaymsg -mt subscribe '[]' || true"
      "systemctl --user stop sway-session.target"
      "systemctl --user stop graphical-session.target"
    ];
    config = {
      bars = [ ];
      gaps = {
        inner = 5;
        outer = 5;
      };
      input = {
        "type:keyboard".xkb_numlock = "enabled";
        "type:touchpad" = {
          natural_scroll = "disabled";
          scroll_factor = "0.5";
          tap = "enabled";
        };
      };
      keybindings = lib.mkOptionDefault {
        # Apps
        "${mod}+e" = "exec dolphin";
        "${mod}+F4" = "${noctalia} panel-toggle session";
        "${mod}+l" = "${noctalia} session lock";
        "${mod}+period" = "${noctalia} panel-toggle launcher /emo";
        "${mod}+q" = "kill";
        "${mod}+Shift+e" = "${noctalia} panel-toggle session";
        "${mod}+space" = "${noctalia} panel-toggle launcher";

        # Audio & media controls
        "${mod}+Shift+a" = "${noctalia} mic-mute";
        "${mod}+Shift+s" = "exec ${lib.getExe cycle-audio-output}";
        "XF86AudioMute" = "${noctalia} volume-mute";
        "XF86AudioNext" = "${noctalia} media next";
        "XF86AudioPlay" = "${noctalia} media toggle";
        "XF86AudioPrev" = "${noctalia} media previous";

        # Screenshot
        "Print" = "${noctalia} screenshot-region";

        # Volume/brightness
        "--locked XF86AudioLowerVolume" = "${noctalia} volume-down";
        "--locked XF86AudioRaiseVolume" = "${noctalia} volume-up";
        "--locked XF86KbdBrightnessDown" = "${noctalia} keyboard-backlight-down";
        "--locked XF86KbdBrightnessUp" = "${noctalia} keyboard-backlight-up";
        "--locked XF86MonBrightnessDown" = "${noctalia} brightness-down";
        "--locked XF86MonBrightnessUp" = "${noctalia} brightness-up";

        # Unbinds
        "${mod}+0" = "null";
        "${mod}+Shift+0" = "null";
      };
      menu = "noctalia msg panel-toggle launcher";
      modifier = "Mod4";
      startup = [
        {
          always = true;
          command = "${pkgs.autotiling-rs}/bin/autotiling-rs";
        }
      ];
      terminal = "kitty";
      window = {
        border = 1;
        titlebar = false;
      };
    };
  };
}
