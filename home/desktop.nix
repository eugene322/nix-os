# User-level desktop apps. kitty terminal here; Hyprland/waybar/rofi configs
# can be added to this file as you flesh out the desktop.
{ ... }:
{
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
}
