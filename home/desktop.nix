# User-level desktop configuration: Hyprland, waybar, rofi, terminal.
{ pkgs, lib, ... }:
{
  # Terminal emulator
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 13;
    };
    settings = {
      # terminal opacity is managed by stylix (opacity.terminal)
      scrollback_lines = 10000;
      enable_audio_bell = false;
      window_padding_width = 8;
      confirm_os_window_close = 0;
    };
  };

  # Hyprland wayland compositor
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;
    configType = "lua"; # current/recommended format (hyprlang is legacy as of hyprland 0.55+)

    settings =
      let
        # helpers to build raw hl.dsp.* Lua expressions for use as bind() arguments
        dsp = luaExpr: lib.generators.mkLuaInline luaExpr;
        exec = cmd: dsp ("hl.dsp.exec_cmd(" + builtins.toJSON cmd + ")");
        focusDir = dir: dsp ''hl.dsp.focus({ direction = "${dir}" })'';
        moveDir = dir: dsp ''hl.dsp.window.move({ direction = "${dir}" })'';
        focusWs = ws: dsp ("hl.dsp.focus({ workspace = " + builtins.toJSON ws + " })");
        moveWs = ws: dsp ("hl.dsp.window.move({ workspace = " + builtins.toJSON ws + " })");
      in
      {
        # Monitor configuration (adjust for your setup)
        monitor = [
          {
            output = ""; # Auto-detect monitors
            mode = "preferred";
            position = "auto";
            scale = 1;
          }
          # Examples for specific setups:
          # { output = "DP-1"; mode = "1920x1080@144"; position = "0x0"; scale = 1; }
        ];

        # Autostart applications
        on = [
          {
            _args = [
              "hyprland.start"
              (lib.generators.mkLuaInline ''
                function()
                  hl.exec_cmd("waybar")
                  hl.exec_cmd("dunst") -- notification daemon
                  hl.exec_cmd("wl-paste --type text --watch cliphist store") -- clipboard history
                  hl.exec_cmd("wl-paste --type image --watch cliphist store")
                end''
              )
            ];
          }
        ];

        config = {
          # Input configuration
          input = {
            kb_layout = "us,ru";
            kb_options = "grp:alt_shift_toggle";
            follow_mouse = 1;
            sensitivity = 0; # -1.0 to 1.0, 0 means no modification
            touchpad = {
              natural_scroll = true;
              disable_while_typing = true;
            };
          };

          # General window and border settings
          general = {
            gaps_in = 5;
            gaps_out = 10;
            border_size = 2;
            # Colors managed by stylix
            layout = "dwindle";
            resize_on_border = true;
          };

          # Decoration (rounded corners, blur, shadows)
          decoration = {
            rounding = 8;
            active_opacity = 1.0;
            inactive_opacity = 0.95;

            blur = {
              enabled = true;
              size = 6;
              passes = 3;
              new_optimizations = true;
              ignore_opacity = true;
            };

            shadow = {
              enabled = true;
              range = 20;
              render_power = 3;
            };
          };

          animations = {
            enabled = true;
          };

          # Dwindle layout settings
          dwindle = {
            preserve_split = true;
            smart_split = false;
          };

          # Master layout settings
          master = {
            new_status = "master";
            new_on_top = false;
          };

          # Misc settings
          misc = {
            disable_hyprland_logo = true;
            disable_splash_rendering = true;
            mouse_move_enables_dpms = true;
            key_press_enables_dpms = true;
            vrr = 1; # Variable refresh rate (0 = off, 1 = on, 2 = fullscreen only)
          };
        };

        # Animation curves (replaces hyprlang `bezier`)
        curve = [
          {
            _args = [
              "smoothOut"
              {
                type = "bezier";
                points = [
                  [
                    0.36
                    0
                  ]
                  [
                    0.66
                    (-0.56)
                  ]
                ];
              }
            ];
          }
          {
            _args = [
              "smoothIn"
              {
                type = "bezier";
                points = [
                  [
                    0.25
                    1
                  ]
                  [
                    0.5
                    1
                  ]
                ];
              }
            ];
          }
          {
            _args = [
              "overshot"
              {
                type = "bezier";
                points = [
                  [
                    0.4
                    0.8
                  ]
                  [
                    0.2
                    1.2
                  ]
                ];
              }
            ];
          }
        ];

        # Animations (replaces hyprlang `animation` list)
        animation = [
          {
            leaf = "windows";
            enabled = true;
            speed = 4;
            bezier = "overshot";
            style = "slide";
          }
          {
            leaf = "windowsOut";
            enabled = true;
            speed = 4;
            bezier = "smoothOut";
            style = "slide";
          }
          {
            leaf = "border";
            enabled = true;
            speed = 10;
            bezier = "default";
          }
          {
            leaf = "fade";
            enabled = true;
            speed = 10;
            bezier = "smoothIn";
          }
          {
            leaf = "fadeDim";
            enabled = true;
            speed = 10;
            bezier = "smoothIn";
          }
          {
            leaf = "workspaces";
            enabled = true;
            speed = 5;
            bezier = "overshot";
            style = "slidevert";
          }
        ];

        # Trackpad workspace swipe (replaces hyprlang gestures:workspace_swipe*)
        gesture = [
          {
            fingers = 3;
            direction = "horizontal";
            action = "workspace";
          }
        ];

        # Window rules (replaces hyprlang windowrulev2)
        window_rule = [
          {
            name = "float-pavucontrol";
            match.class = "(pavucontrol)";
            float = true;
          }
          {
            name = "float-nm-connection-editor";
            match.class = "(nm-connection-editor)";
            float = true;
          }
          {
            name = "float-pip";
            match.title = "(Picture-in-Picture)";
            float = true;
          }
          {
            name = "opacity-kitty";
            match.class = "(kitty)";
            opacity = "0.95 0.85";
          }
          {
            name = "opacity-code";
            match.class = "(Code)";
            opacity = "0.95 0.85";
          }
          {
            name = "workspace-firefox";
            match.class = "(firefox)";
            workspace = "2 silent";
          }
          {
            name = "workspace-code";
            match.class = "(Code)";
            workspace = "3 silent";
          }
          {
            name = "idleinhibit-mpv";
            match.class = "(mpv)";
            idle_inhibit = "focus";
          }
          {
            name = "idleinhibit-youtube";
            match = {
              class = "(firefox)";
              title = "(.*YouTube.*)";
            };
            idle_inhibit = "focus";
          }
        ];

        # Layer rules (for waybar, rofi, etc)
        layer_rule = [
          {
            name = "waybar-layer";
            match.namespace = "waybar";
            blur = true;
            ignore_alpha = 0;
          }
          {
            name = "rofi-layer";
            match.namespace = "rofi";
            blur = true;
            ignore_alpha = 0;
          }
        ];

        # Keybindings
        bind = [
          # Basics
          {
            _args = [
              "SUPER + Return"
              (exec "kitty")
            ];
          }
          {
            _args = [
              "SUPER + Q"
              (dsp "hl.dsp.window.close()")
            ];
          }
          {
            _args = [
              "SUPER + M" # Exit Hyprland
              (dsp "hl.dsp.exit()")
            ];
          }
          {
            _args = [
              "SUPER + E" # File manager
              (exec "thunar")
            ];
          }
          {
            _args = [
              "SUPER + V"
              (dsp ''hl.dsp.window.float({ action = "toggle" })'')
            ];
          }
          {
            _args = [
              "SUPER + D"
              (exec "rofi -show drun")
            ];
          }
          {
            _args = [
              "SUPER + P" # dwindle
              (dsp "hl.dsp.window.pseudo()")
            ];
          }
          {
            _args = [
              "SUPER + F"
              (dsp ''hl.dsp.window.fullscreen({ action = "toggle" })'')
            ];
          }
          {
            _args = [
              "SUPER + B"
              (exec "firefox")
            ];
          }

          # Window focus
          {
            _args = [
              "SUPER + left"
              (focusDir "left")
            ];
          }
          {
            _args = [
              "SUPER + right"
              (focusDir "right")
            ];
          }
          {
            _args = [
              "SUPER + up"
              (focusDir "up")
            ];
          }
          {
            _args = [
              "SUPER + down"
              (focusDir "down")
            ];
          }
          {
            _args = [
              "SUPER + H"
              (focusDir "left")
            ];
          }
          {
            _args = [
              "SUPER + L"
              (focusDir "right")
            ];
          }
          {
            _args = [
              "SUPER + K"
              (focusDir "up")
            ];
          }
          {
            _args = [
              "SUPER + J"
              (focusDir "down")
            ];
          }

          # Window movement
          {
            _args = [
              "SUPER + SHIFT + left"
              (moveDir "left")
            ];
          }
          {
            _args = [
              "SUPER + SHIFT + right"
              (moveDir "right")
            ];
          }
          {
            _args = [
              "SUPER + SHIFT + up"
              (moveDir "up")
            ];
          }
          {
            _args = [
              "SUPER + SHIFT + down"
              (moveDir "down")
            ];
          }
          {
            _args = [
              "SUPER + SHIFT + H"
              (moveDir "left")
            ];
          }
          {
            _args = [
              "SUPER + SHIFT + L"
              (moveDir "right")
            ];
          }
          {
            _args = [
              "SUPER + SHIFT + K"
              (moveDir "up")
            ];
          }
          {
            _args = [
              "SUPER + SHIFT + J"
              (moveDir "down")
            ];
          }

          # Workspace switching
          {
            _args = [
              "SUPER + 1"
              (focusWs 1)
            ];
          }
          {
            _args = [
              "SUPER + 2"
              (focusWs 2)
            ];
          }
          {
            _args = [
              "SUPER + 3"
              (focusWs 3)
            ];
          }
          {
            _args = [
              "SUPER + 4"
              (focusWs 4)
            ];
          }
          {
            _args = [
              "SUPER + 5"
              (focusWs 5)
            ];
          }
          {
            _args = [
              "SUPER + 6"
              (focusWs 6)
            ];
          }
          {
            _args = [
              "SUPER + 7"
              (focusWs 7)
            ];
          }
          {
            _args = [
              "SUPER + 8"
              (focusWs 8)
            ];
          }
          {
            _args = [
              "SUPER + 9"
              (focusWs 9)
            ];
          }
          {
            _args = [
              "SUPER + 0"
              (focusWs 10)
            ];
          }

          # Move window to workspace
          {
            _args = [
              "SUPER + SHIFT + 1"
              (moveWs 1)
            ];
          }
          {
            _args = [
              "SUPER + SHIFT + 2"
              (moveWs 2)
            ];
          }
          {
            _args = [
              "SUPER + SHIFT + 3"
              (moveWs 3)
            ];
          }
          {
            _args = [
              "SUPER + SHIFT + 4"
              (moveWs 4)
            ];
          }
          {
            _args = [
              "SUPER + SHIFT + 5"
              (moveWs 5)
            ];
          }
          {
            _args = [
              "SUPER + SHIFT + 6"
              (moveWs 6)
            ];
          }
          {
            _args = [
              "SUPER + SHIFT + 7"
              (moveWs 7)
            ];
          }
          {
            _args = [
              "SUPER + SHIFT + 8"
              (moveWs 8)
            ];
          }
          {
            _args = [
              "SUPER + SHIFT + 9"
              (moveWs 9)
            ];
          }
          {
            _args = [
              "SUPER + SHIFT + 0"
              (moveWs 10)
            ];
          }

          # Special workspaces (scratchpad)
          {
            _args = [
              "SUPER + S"
              (dsp ''hl.dsp.workspace.toggle_special("magic")'')
            ];
          }
          {
            _args = [
              "SUPER + SHIFT + S"
              (moveWs "special:magic")
            ];
          }

          # Scroll through workspaces
          {
            _args = [
              "SUPER + mouse_down"
              (focusWs "e+1")
            ];
          }
          {
            _args = [
              "SUPER + mouse_up"
              (focusWs "e-1")
            ];
          }

          # Screenshots
          {
            _args = [
              "Print"
              (exec "grimblast copy area")
            ];
          }
          {
            _args = [
              "SHIFT + Print"
              (exec "grimblast copy screen")
            ];
          }
          {
            _args = [
              "SUPER + Print"
              (exec "grimblast save area ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png")
            ];
          }

          # Clipboard history
          {
            _args = [
              "SUPER + C"
              (exec "cliphist list | rofi -dmenu | cliphist decode | wl-copy")
            ];
          }

          # Media controls (next/prev; play/pause/mute/volume/brightness below carry locked/repeating flags)
          {
            _args = [
              "XF86AudioNext"
              (exec "playerctl next")
            ];
          }
          {
            _args = [
              "XF86AudioPrev"
              (exec "playerctl previous")
            ];
          }

          # Locked bindings (work even when locked)
          {
            _args = [
              "XF86AudioMute"
              (exec "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
              { locked = true; }
            ];
          }
          {
            _args = [
              "XF86AudioPlay"
              (exec "playerctl play-pause")
              { locked = true; }
            ];
          }
          {
            _args = [
              "XF86AudioPause"
              (exec "playerctl play-pause")
              { locked = true; }
            ];
          }

          # Repeat bindings (hold key to repeat)
          {
            _args = [
              "XF86AudioLowerVolume"
              (exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")
              { repeating = true; }
            ];
          }
          {
            _args = [
              "XF86AudioRaiseVolume"
              (exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+")
              { repeating = true; }
            ];
          }
          {
            _args = [
              "XF86MonBrightnessUp"
              (exec "brightnessctl set 5%+")
              { repeating = true; }
            ];
          }
          {
            _args = [
              "XF86MonBrightnessDown"
              (exec "brightnessctl set 5%-")
              { repeating = true; }
            ];
          }

          # Mouse bindings
          {
            _args = [
              "SUPER + mouse:272"
              (dsp "hl.dsp.window.drag()")
              { mouse = true; }
            ];
          }
          {
            _args = [
              "SUPER + mouse:273"
              (dsp "hl.dsp.window.resize()")
              { mouse = true; }
            ];
          }
        ];
      };
  };

  # Waybar status bar
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 35;
        spacing = 4;

        modules-left = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "pulseaudio" "network" "cpu" "memory" "battery" "tray" ];

        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            "1" = "一";
            "2" = "二";
            "3" = "三";
            "4" = "四";
            "5" = "五";
            "6" = "六";
            "7" = "七";
            "8" = "八";
            "9" = "九";
            "10" = "十";
          };
          persistent-workspaces = {
            "*" = 5; # 5 workspaces on all monitors
          };
        };

        "hyprland/window" = {
          max-length = 50;
          separate-outputs = true;
        };

        clock = {
          format = "{:%H:%M}";
          format-alt = "{:%Y-%m-%d %H:%M:%S}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "month";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            format = {
              months = "<span color='#ffead3'><b>{}</b></span>";
              days = "<span color='#ecc6d9'><b>{}</b></span>";
              weeks = "<span color='#99ffdd'><b>W{}</b></span>";
              weekdays = "<span color='#ffcc66'><b>{}</b></span>";
              today = "<span color='#ff6699'><b><u>{}</u></b></span>";
            };
          };
        };

        cpu = {
          format = " {usage}%";
          tooltip = false;
        };

        memory = {
          format = " {}%";
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          format-plugged = " {capacity}%";
          format-icons = [ "" "" "" "" "" ];
        };

        network = {
          format-wifi = " {essid}";
          format-ethernet = " {ipaddr}";
          format-disconnected = "⚠ Disconnected";
          tooltip-format = "{ifname} via {gwaddr}";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = " muted";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [ "" "" "" ];
          };
          on-click = "pavucontrol";
        };

        tray = {
          spacing = 10;
        };
      };
    };

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background: transparent;
      }

      #workspaces button {
        padding: 0 8px;
        background: transparent;
        color: #cdd6f4;
        border-radius: 8px;
        margin: 4px;
      }

      #workspaces button.active {
        background: rgba(205, 214, 244, 0.15);
        color: #89b4fa;
      }

      #workspaces button:hover {
        background: rgba(205, 214, 244, 0.1);
      }

      #window,
      #clock,
      #battery,
      #cpu,
      #memory,
      #network,
      #pulseaudio,
      #tray {
        padding: 0 12px;
        margin: 4px 2px;
        background: rgba(30, 30, 46, 0.8);
        border-radius: 8px;
      }

      #battery.charging {
        color: #a6e3a1;
      }

      #battery.warning:not(.charging) {
        color: #f9e2af;
      }

      #battery.critical:not(.charging) {
        color: #f38ba8;
      }

      #pulseaudio.muted {
        color: #6c7086;
      }
    '';
  };

  # Rofi launcher
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    extraConfig = {
      modi = "drun,run,filebrowser,window";
      show-icons = true;
      display-drun = " Apps";
      display-run = " Run";
      display-filebrowser = " Files";
      display-window = " Windows";
      drun-display-format = "{name}";
      window-format = "{w} · {c} · {t}";
    };
    # Styling handled by stylix
  };

  # File manager (optional, but useful)
  home.packages = with pkgs; [
    thunar # GUI file manager
    grim # screenshot utility (used by grimblast)
    slurp # screen area selector (used by grimblast)
    pavucontrol # PulseAudio/PipeWire volume control
  ];

  # Create screenshots directory
  home.file.".config/hypr/.keep".text = "";
  xdg.userDirs.pictures = "$HOME/Pictures";
}
