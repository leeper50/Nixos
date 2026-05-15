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
    xwayland.enable = true;

    settings = {
      # Machine-specific monitor settings (https://wiki.hyprland.org/Configuring/Monitors/)
      source = [ "~/.config/hypr/monitors.conf" ];

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
        "easyeffect --hide-window"
      ];

      input = {
        follow_mouse = 1;
        numlock_by_default = true;
        touchpad.natural_scroll = false;
      };

      general = {
        border_size = 2;
        gaps_in = 5;
        gaps_out = 10;
        layout = "dwindle";
      };

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

      animations = {
        enabled = true;
        bezier = "easeOut, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, easeOut"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      dwindle = {
        preserve_split = true;
      };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
      };

      "$mod" = "SUPER";

      bind = [
        "$mod, Return, exec, kitty"
        "$mod, period, exec, rofimoji --selector fuzzel --action copy"
        "$mod, Q, killactive"
        "$mod, E, exec, dolphin"
        "$mod, V, togglefloating"
        "$mod, D, exec, fuzzel"
        "$mod, F, fullscreen"
        "$mod, L, exec, hyprlock"
        "ALT SHIFT, T, pin"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        "$mod SHIFT, A, exec, pactl set-source-mute @DEFAULT_SOURCE@ toggle"
        # screenshot: select area, copy to clipboard
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
        # focus
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        # move window
        "$mod SHIFT, left, movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up, movewindow, u"
        "$mod SHIFT, down, movewindow, d"
        # workspaces
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        # move window to workspace
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      bindel = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
        ", XF86KbdBrightnessUp, exec, brightnessctl -d '*::kbd_backlight' set +10%"
        ", XF86KbdBrightnessDown, exec, brightnessctl -d '*::kbd_backlight' set 10%-"
      ];

    };
  };

  programs.waybar = {
    enable = true;
    style = ''
      * { font-size: 15px; }
    '';
    systemd = {
      enable = true;
      targets = [ "hyprland-session.target" ];
    };
    settings = [
      {
        layer = "top";
        position = "top";
        height = 36;
        spacing = 24;

        modules-left = [
          "hyprland/workspaces"
        ];
        modules-center = [ "clock" ];
        modules-right = [
          "tray"
          "network"
          "battery"
          "pulseaudio"
          "power-profiles-daemon"
        ];

        "hyprland/workspaces" = {
          format = "{name}";
          on-click = "activate";
          sort-by-number = true;
        };

        "hyprland/window" = {
          max-length = 60;
          separate-outputs = true;
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
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
          tooltip = true;
        };

        bluetooth = {
          format = "BT {status}";
          format-connected = "BT {device_alias}";
          tooltip-format-connected = "{controller_alias}\n{device_enumerate}";
          on-click = "blueman-manager";
        };

        clock = {
          format = "{:%Y-%m-%d | %H:%M}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        network = {
          format = "";
          format-disconnected = "Disconnected";
          tooltip-format = "{ifname}: {ipaddr}";
        };

        "power-profiles-daemon" = {
          format = "{icon}  ";
          tooltip-format = "{profile}";
          format-icons = {
            "balanced" = "🌿";
            "performance" = "⚖️";
            "power-saver" = "🚀";
          };
        };

        pulseaudio = {
          format = "{volume}% - {desc}";
          format-muted = "Muted - {desc}";
          on-click = "${cycle-audio-output}";
          scroll-step = 2;
        };

        tray = {
          spacing = 8;
          icon-size = 24;
        };
      }
    ];
  };

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "kitty";
        icons-enabled = true;
        font = lib.mkForce "Fira Code:size=14";
        width = 40;
        lines = 15;
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
          path = "${./wallpaper.jxl}";
          blur_size = 4;
          blur_passes = 3;
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
}
