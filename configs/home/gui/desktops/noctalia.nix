# Docs: https://docs.noctalia.dev/noctalia/
{
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    settings = {
      bar.default = {
        margin_ends = 0;
        radius = 0;
        start = [
          "workspaces"
        ];
        center = [
          "clock"
          "notifications"
        ];
        end = [
          "tray"
          "clipboard"
          "bluetooth"
          "volume"
          "brightness"
          "battery"
        ];
      };
      brightness.minimum_brightness = 0.05;
      shell.launcher = {
        app_grid = true;
        categories = false;
        default_view = "all";
        layout = "simple";
        show_session_button = false;
        show_settings_button = false;
        track_usage = false;
      };
    };
  };
  stylix.targets.noctalia.enable = true;
  systemd.user.services.noctalia.Unit = {
    After = [ "pipewire.service" ];
    PartOf = [ "pipewire.service" ];
  };
}
