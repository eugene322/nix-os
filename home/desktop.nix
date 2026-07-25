# User-level desktop configuration: Hyprland, waybar, rofi, terminal.
{
  pkgs,
  lib,
  osConfig,
  ...
}:
{
  # Terminal emulator
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 14;
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
        isDesktop = osConfig.networking.hostName == "desktop";
      in
      {
        # Monitor configuration
        monitor = lib.mkIf isDesktop [
          {
            output = "DP-1";
            mode = "2560x1440@120.00Hz";
            position = "1920x0";
            scale = 1;
          }
          {
            output = "HDMI-A-1";
            mode = "1920x1080@60.00Hz";
            position = "0x0";
            scale = 1;
          }
        ];

        config = {
          # Input configuration
          input = {
            kb_layout = "us,ru";
            kb_options = "grp:alt_shift_toggle";
            follow_mouse = 1;
            sensitivity = 0; # -1.0 to 1.0, 0 means no modification
            numlock_by_default = true;
            touchpad = {
              natural_scroll = true;
              disable_while_typing = true;
            };
          };
        };

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
              "SUPER + D" # App runner
              (exec "rofi -show drun")
            ];
          }
          {
            _args = [
              "SUPER + F" # Full screen
              (dsp ''hl.dsp.window.fullscreen({ action = "toggle" })'')
            ];
          }
          {
            _args = [
              "SUPER + B" # Browser
              (exec "brave")
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
        ]
        # Workspace switching + move window to workspace
        # binds $mod + [shift +] {1..9,0} to [move to] workspace {1..10}
        ++ builtins.concatLists (
          builtins.genList (
            i:
            let
              ws = i + 1;
              key = if ws == 10 then "0" else toString ws;
            in
            [
              {
                _args = [
                  "SUPER + ${key}"
                  (focusWs ws)
                ];
              }
              {
                _args = [
                  "SUPER + SHIFT + ${key}"
                  (moveWs ws)
                ];
              }
            ]
          ) 10
        );
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

        modules-left = [
          "hyprland/workspaces"
          "hyprland/window"
        ];
        modules-center = [ "clock" ];
        modules-right = [
          "pulseaudio"
          "network"
          "cpu"
          "memory"
          "tray"
        ];

        "hyprland/workspaces" = {
          format = "{icon} {windows}";
          format-icons = {
            "active" =  "◉";
            "default" = "○";
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
            default = [
              ""
              ""
              ""
            ];
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
