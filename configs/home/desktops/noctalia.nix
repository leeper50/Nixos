{
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    settings = {
      bar.default = {
        start = [
          "workspaces"
        ];
        center = [
          "clock"
          "media"
        ];
        end = [
          "tray"
          "notifications"
          "clipboard"
          "bluetooth"
          "privacy"
          "volume"
          "brightness"
          "battery"
        ];
      };
      brightness.minimum_brightness = 0.05;
      location.auto_locate = true;
      widget = {
        media.hide_when_no_media = true;
      };
    };
  };
  stylix.targets.noctalia.enable = true;
}
