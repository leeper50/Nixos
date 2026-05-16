{ lib, pkgs, ... }:
let
  cycle-audio-output = pkgs.writeShellScript "cycle-audio-output" ''
    current=$(pactl get-default-sink)
    sinks=$(pactl list sinks short | awk '{print $2}' | grep -v easyeffects)
    count=$(echo "$sinks" | wc -l)

    current_idx=0
    i=0
    while IFS= read -r sink; do
      if [ "$sink" = "$current" ]; then current_idx=$i; fi
      i=$((i + 1))
    done <<< "$sinks"

    next_sink=$(echo "$sinks" | sed -n "$(( (current_idx + 1) % count + 1 ))p")
    pactl set-default-sink "$next_sink"
    pactl list sink-inputs short | awk '{print $1}' | while read -r id; do
      pactl move-sink-input "$id" "$next_sink"
    done
  '';
in
{
  home.packages = with pkgs; [
    blueman
    brightnessctl
    grim
    pavucontrol
    playerctl
    rofimoji
    slurp
    wl-clipboard
    wtype
    xdg-desktop-portal-hyprland
  ];

  wayland.windowManager.hyprland = {
    configType = "hyprlang";
    enable = true;
    package = null; # null package for non-nixos hosts
    settings = {
      "$mod" = "SUPER";

      animations = {
        animation = [
          "windows, 1, 7, easeOut"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
        bezier = "easeOut, 0.05, 0.9, 0.1, 1.05";
        enabled = true;
      };

      bind = [
        "$mod, D, exec, fuzzel"
        "$mod, E, exec, dolphin"
        "$mod, F, fullscreen"
        "$mod, L, exec, hyprlock"
        "$mod, period, exec, rofimoji --selector fuzzel --action copy"
        "$mod, Q, killactive"
        "$mod, Return, exec, kitty"
        "$mod, V, togglefloating"
        "$mod, W, exec, kitty"
        "alt, F4, killactive"
        # screenshot: select area, copy to clipboard
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
        # Focus
        "$mod, down, movefocus, d"
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        # Move window
        "$mod SHIFT, down, movewindow, d"
        "$mod SHIFT, left, movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up, movewindow, u"
        # Workspaces
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        # Move window to workspace
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        # Audio & Media controls
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_SINK@ toggle"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
        "$mod SHIFT, A, exec, wpctl set-mute @DEFAULT_SOURCE@ toggle"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      bindel = [
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_SINK@ 5%-"
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.0 @DEFAULT_SINK@ 5%+"
        ", XF86KbdBrightnessDown, exec, brightnessctl -d '*::kbd_backlight' set 10%-"
        ", XF86KbdBrightnessUp, exec, brightnessctl -d '*::kbd_backlight' set +10%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
        ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
      ];

      env = [
        "GDK_BACKEND,wayland,x11"
        "MOZ_ENABLE_WAYLAND,1"
        "NIXOS_OZONE_WL,1"
        "QT_QPA_PLATFORM,wayland;xcb"
        "QT_QPA_PLATFORMTHEME,kde"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
      ];

      exec-once = [
        # Source my wacky things
        ". $HOME/.nix-profile/etc/profile.d/nix.sh && systemctl --user import-environment PATH && systemctl --user start hyprland-session.target"
        "easyeffects --hide-window"
      ];

      decoration = {
        active_opacity = 1.0;
        blur = {
          enabled = true;
          noise = 0.01;
          passes = 2;
          size = 10;
        };
        inactive_opacity = 0.95;
        rounding = 4;
        shadow.enabled = true;
      };

      dwindle = {
        precise_mouse_move = true;
        smart_split = true;
      };

      general = {
        border_size = 1;
        gaps_in = 5;
        gaps_out = 10;
        layout = "dwindle";
      };

      input = {
        follow_mouse = 1;
        numlock_by_default = true;
        touchpad.natural_scroll = false;
      };

      misc = {
        disable_hyprland_logo = true;
        enable_swallow = true;
        force_default_wallpaper = 0;
        swallow_regex = "^kitty";
        vrr = 1;
      };

      # Machine-specific monitor settings (https://wiki.hyprland.org/Configuring/Monitors/)
      source = [ "~/.config/hypr/monitors.conf" ];
    };
    xwayland.enable = true;
  };

  programs.waybar = {
    enable = true;
    settings = [
      {
        layer = "top";
        position = "top";
        height = 36;
        spacing = 24;

        modules-left = [
          "hyprland/workspaces"
        ];
        modules-center = [
          "clock"
        ];
        modules-right = [
          "tray"
          "network"
          "battery"
          "pulseaudio"
          "pulseaudio#microphone"
          "power-profiles-daemon"
        ];

        battery = {
          format = "{capacity}% {icon}";
          format-charging = "{capacity}% +";
          format-icons = [
            "▁"
            "▂"
            "▃"
            "▄"
            "▅"
            "▆"
            "▇"
            "█"
          ];
          states = {
            critical = 15;
            warning = 30;
          };
          tooltip = true;
        };

        bluetooth = {
          format = "BT {status}";
          format-connected = "BT {device_alias}";
          on-click = "blueman-manager";
          tooltip-format-connected = "{controller_alias}\n{device_enumerate}";
        };

        clock = {
          format = "{:%Y-%m-%d | %H:%M}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        "hyprland/workspaces" = {
          format = "{name}";
          on-click = "activate";
          sort-by-number = true;
        };

        "hyprland/window" = {
          max-length = 60;
          separate-outputs = true;
        };

        network = {
          format = "";
          format-disconnected = "Disconnected";
          tooltip-format = "{ifname}: {ipaddr}";
        };

        "power-profiles-daemon" = {
          format = "{icon}  ";
          format-icons = {
            "balanced" = "⚖️";
            "performance" = "🚀";
            "power-saver" = "🌿";
          };
          tooltip-format = "{profile}";
        };

        pulseaudio = {
          format = "{volume}% - {desc}";
          format-muted = "Muted - {desc}";
          on-click = "${cycle-audio-output}";
          scroll-step = 5;
        };

        "pulseaudio#microphone" = {
          format = "{format_source}";
          format-source = "{volume}% - 🎤";
          format-source-muted = "Muted - 🎤";
          on-click = "wpctl set-mute @DEFAULT_SOURCE@ toggle";
          on-scroll-up = "wpctl set-volume -l 1.0 @DEFAULT_SOURCE@ 5%+";
          on-scroll-down = "wpctl set-volume @DEFAULT_SOURCE@ 5%-";
          tooltip-format = "{source_desc}";
        };

        tray = {
          spacing = 8;
          icon-size = 24;
        };
      }
    ];
    style = ''
      * { font-size: 15px; }
    '';
    systemd = {
      enable = true;
      targets = [ "hyprland-session.target" ];
    };
  };

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = lib.mkForce "Fira Code:size=14";
        icons-enabled = true;
        lines = 15;
        terminal = "kitty";
        width = 40;
      };
    };
  };

  services.dunst = {
    enable = true;
    iconTheme = {
      name = lib.mkForce "Papirus-Dark";
      size = "32x32";
    };
    settings = {
      global = {
        corner_radius = 10;
        follow = "keyboard";
        frame_width = 2;
        gap_size = 5;
        offset = "10x10";
        width = 350;
      };
    };
  };

  programs.hyprlock = {
    enable = true;
    package = null;
    settings = {
      background = lib.mkForce [
        {
          blur_passes = 3;
          blur_size = 4;
          path = "${./wallpaper.jxl}";
        }
      ];
      general = {
        disable_loading_bar = true;
        hide_cursor = true;
      };
    };
  };

  stylix.targets = {
    dunst.enable = true;
    fuzzel.enable = true;
    hyprland.enable = true;
    hyprlock.enable = true;
    waybar.enable = true;
  };

  xdg.portal.config.common.default = "*";

  # Get dolphin working with hyprland
  home.file.".config/menus/applications.menu".text = ''
    <!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN"
      "http://www.freedesktop.org/standards/menu-spec/menu-1.0.dtd">
    <Menu>
      <Name>Applications</Name>
      <DefaultAppDirs/>
      <DefaultDirectoryDirs/>
      <DefaultMergeDirs/>
    </Menu>
  '';
}
