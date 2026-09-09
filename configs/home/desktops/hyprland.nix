{
  config,
  lib,
  pkgs,
  ...
}:
let
  cycle-audio-output = pkgs.writeShellScript "cycle-audio-output" ''
    current=$(${pactl} get-default-sink)
    sinks=$(${pactl} list sinks short | awk '{print $2}' | rg alsa_output)
    count=$(echo "$sinks" | wc -l)

    current_idx=0
    i=0
    while IFS= read -r sink; do
      if [ "$sink" = "$current" ]; then current_idx=$i; fi
      i=$((i + 1))
    done <<< "$sinks"

    next_sink=$(echo "$sinks" | sed -n "$(( (current_idx + 1) % count + 1 ))p")
    ${pactl} set-default-sink "$next_sink"
    ${pactl} list sink-inputs short | awk '{print $1}' | while read -r id; do
      ${pactl} move-sink-input "$id" "$next_sink"
    done
  '';
  pactl = "${pkgs.pulseaudio}/bin/pactl";
in
{
  home.file.".config/kwalletrc".text = ''
    [Wallet]
    First Use=false
    [KSecretD]
    Enabled=false
  '';

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

  home.packages = with pkgs; [
    blueman
    brightnessctl
    grim
    hyprpolkitagent
    pavucontrol
    playerctl
    rofimoji
    slurp
    waypaper
    wl-clip-persist
    wl-clipboard
    wtype
    xdg-desktop-portal-hyprland
  ];

  programs = {
    waybar = {
      enable = true;
      settings = [
        {
          height = 36;
          layer = "top";
          position = "top";
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
            on-click-right = "wpctl set-mute @DEFAULT_SINK@ toggle";
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
    fuzzel = {
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
    hyprlock = {
      enable = true;
      package = null;
      settings = {
        background = lib.mkForce [
          {
            blur_passes = 3;
            blur_size = 4;
            path = "${../wallpaper.jxl}";
          }
        ];
        general = {
          disable_loading_bar = true;
          hide_cursor = true;
        };
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

  systemd.user = {
    services = {
      hyprpolkitagent = {
        Unit = {
          Description = "Polkit authentication agent for Hyprland";
          PartOf = [ "hyprland-session.target" ];
        };
        Install.WantedBy = [ "hyprland-session.target" ];
        Service = {
          ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
          Restart = "on-failure";
        };
      };
      wl-clip-persist = {
        Install.WantedBy = [ "hyprland-session.target" ];
        Service = {
          ExecStart = "${pkgs.wl-clip-persist}/bin/wl-clip-persist --clipboard both";
          Restart = "on-failure";
        };
        Unit = {
          Description = "Keep Wayland clipboard contents after the source app exits";
          PartOf = [ "hyprland-session.target" ];
        };
      };
    };
    tmpfiles.rules = [
      "d ${config.xdg.configHome}/hypr 0750 - - -"
      "f ${config.xdg.configHome}/hypr/monitors.lua 0750 - - -"
    ];
  };

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''
      require("monitors")

      hl.on("hyprland.start", function()
        hl.exec_cmd("easyeffects --hide-window")
      end)
    '';
    extraLuaFiles."binds.lua" = {
      autoLoad = true;
      content = ''
        local mainMod = "SUPER"

        -- Session
        hl.bind(mainMod .. " + F4", hl.dsp.exec_cmd("hyprshutdown"))

        -- Apps
        hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("fuzzel"))
        hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd("fuzzel"))
        hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("dolphin"))
        hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
        hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
        hl.bind(mainMod .. " + Period", hl.dsp.exec_cmd("rofimoji --selector fuzzel --action copy"))
        hl.bind(mainMod .. " + Q", hl.dsp.window.close())
        hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("kitty"))
        hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
        hl.bind("ALT + F4", hl.dsp.window.close())

        -- Screenshot
        hl.bind("Print", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))

        -- Focus
        hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))
        hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
        hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
        hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))

        -- Move window within layout
        hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))
        hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
        hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
        hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))

        -- Workspaces
        for i = 1, 10 do
          local key = i % 10
          hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
          hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
        end

        -- Mouse move/resize
        hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
        hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

        -- Audio & media controls
        hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SINK@ toggle"))
        hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
        hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
        hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))
        hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SOURCE@ toggle"))

        -- Volume/brightness
        hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_SINK@ 5%-"), { locked = true, repeating = true })
        hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_SINK@ 5%+"), { locked = true, repeating = true })
        hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd("brightnessctl -d '*::kbd_backlight' set 10%- -n 0"), { locked = true, repeating = true })
        hl.bind("XF86KbdBrightnessUp", hl.dsp.exec_cmd("brightnessctl -d '*::kbd_backlight' set +10%"), { locked = true, repeating = true })
        hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%- -n 5"), { locked = true, repeating = true })
        hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +5%"), { locked = true, repeating = true })
      '';
    };
    package = null;
    settings = {
      animation = [
        {
          bezier = "easeOut";
          enabled = true;
          leaf = "windows";
          speed = 7;
        }
        {
          leaf = "windowsOut";
          enabled = true;
          speed = 7;
          bezier = "default";
          style = "popin 80%";
        }
        {
          bezier = "default";
          enabled = true;
          leaf = "border";
          speed = 10;
        }
        {
          bezier = "default";
          enabled = true;
          leaf = "fade";
          speed = 7;
        }
        {
          bezier = "default";
          enabled = true;
          leaf = "workspaces";
          speed = 6;
        }
      ];
      config = {
        general = {
          border_size = 1;
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
          rounding = 4;
          shadow.enabled = true;
        };
        animations.enabled = true;
        dwindle = {
          precise_mouse_move = true;
          smart_split = true;
        };
        misc = {
          disable_hyprland_logo = true;
          enable_swallow = true;
          force_default_wallpaper = 0;
          swallow_regex = "^kitty";
          vrr = 0;
        };
        input = {
          follow_mouse = 1;
          numlock_by_default = true;
          touchpad = {
            natural_scroll = false;
            scroll_factor = 0.5;
          };
        };
        xwayland.force_zero_scaling = true;
      };
      curve = {
        _args = [
          "easeOut"
          {
            type = "bezier";
            points = [
              [
                0.05
                0.9
              ]
              [
                0.1
                1.05
              ]
            ];
          }
        ];
      };
      env = [
        {
          _args = [
            "GDK_BACKEND"
            "wayland,x11"
          ];
        }
        {
          _args = [
            "MOZ_ENABLE_WAYLAND"
            "1"
          ];
        }
        {
          _args = [
            "NIXOS_OZONE_WL"
            "1"
          ];
        }
        {
          _args = [
            "QT_QPA_PLATFORM"
            "wayland;xcb"
          ];
        }
        {
          _args = [
            "QT_QPA_PLATFORMTHEME"
            "kde"
          ];
        }
        {
          _args = [
            "QT_WAYLAND_DISABLE_WINDOWDECORATION"
            "1"
          ];
        }
      ];
      gesture = {
        action = "workspace";
        direction = "horizontal";
        fingers = 3;
      };
      monitor = {
        mode = "preferred";
        output = "";
        position = "auto";
        scale = "auto";
      };
    };
    xwayland.enable = true;
  };
  xdg.portal.config.common.default = "*";
}
