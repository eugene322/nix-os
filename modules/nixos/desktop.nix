# Desktop: Hyprland (Wayland tiling compositor) + PipeWire + greetd.
# User-level config (waybar/rofi themes, keybinds) belongs in home/desktop.nix.
{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Portals: screenshots, file pickers, screen sharing.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # Audio via PipeWire (replaces PulseAudio).
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Minimal login manager that launches Hyprland.
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
      user = "greeter";
    };
  };

  environment.systemPackages = with pkgs; [
    waybar # status bar
    rofi-wayland # launcher
    dunst # notifications
    swww # wallpaper daemon
    grimblast # screenshots
    wl-clipboard
    cliphist # clipboard history
    playerctl
    brightnessctl
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-emoji
  ];
}
