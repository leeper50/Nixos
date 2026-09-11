{
  config,
  lib,
  pkgs,
  ...
}:
let
  cycle-audio-output = import ./cycle-audio-output.nix { inherit pkgs; };
in
{
  home.packages = with pkgs; [
    blueman
    pavucontrol
    waypaper
    wl-clipboard
    wtype
    xdg-desktop-portal-hyprland
  ];

  stylix.targets.hyprland.enable = true;

  systemd.user = {
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
        -- hl.exec_cmd("easyeffects --hide-window")
      end)
      hl.on("hyprland.shutdown", function()
        os.execute("uwsm check is-active compositor-only || systemctl --user stop graphical-session.target")
      end)
    '';
    extraLuaFiles."binds.lua" = {
      autoLoad = true;
      content = ''
        local mainMod = "SUPER"
        local noctalia = "noctalia msg "

        -- Session
        hl.bind(mainMod .. " + F4", hl.dsp.exec_cmd(noctalia .. "panel-toggle session"))
        hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd(noctalia .. "panel-toggle session"))

        -- Apps
        hl.bind("ALT + F4", hl.dsp.window.close())
        hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(noctalia .. "panel-toggle launcher"))
        hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("dolphin"))
        hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
        hl.bind(mainMod .. " + L", hl.dsp.exec_cmd(noctalia .. "session lock"))
        hl.bind(mainMod .. " + Period", hl.dsp.exec_cmd(noctalia .. "panel-toggle launcher /emo"))
        hl.bind(mainMod .. " + Q", hl.dsp.window.close())
        hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("kitty"))
        hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd(noctalia .. "panel-toggle launcher"))
        hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))

        -- Screenshot
        hl.bind("Print", hl.dsp.exec_cmd(noctalia .. "screenshot-region"))

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
        for i = 1, 9 do
          local key = i % 9
          hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
          hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
        end

        -- Mouse move/resize
        hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
        hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

        -- Audio & media controls
        hl.bind("XF86AudioMute", hl.dsp.exec_cmd(noctalia .. "volume-mute"))
        hl.bind("XF86AudioNext", hl.dsp.exec_cmd(noctalia .. "media next"))
        hl.bind("XF86AudioPlay", hl.dsp.exec_cmd(noctalia .. "media toggle"))
        hl.bind("XF86AudioPrev", hl.dsp.exec_cmd(noctalia .. "media previous"))
        hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd(noctalia .. "mic-mute"))
        hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("${lib.getExe cycle-audio-output}"))

        -- Volume/brightness
        hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(noctalia .. "volume-down"), { locked = true, repeating = true })
        hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(noctalia .. "volume-up"), { locked = true, repeating = true })
        hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd(noctalia .. "keyboard-backlight-down"), { locked = true, repeating = true })
        hl.bind("XF86KbdBrightnessUp", hl.dsp.exec_cmd(noctalia .. "keyboard-backlight-up"), { locked = true, repeating = true })
        hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(noctalia .. "brightness-down"), { locked = true, repeating = true })
        hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(noctalia .. "brightness-up"), { locked = true, repeating = true })
      '';
    };
    package = null;
    # Under uwsm, uwsm starts the session targets itself
    systemd.extraCommands = [
      "(uwsm check is-active compositor-only || (systemctl --user stop hyprland-session.target && systemctl --user start hyprland-session.target))"
    ];
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
