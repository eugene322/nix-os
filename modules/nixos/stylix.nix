# System-wide theming with Stylix.
#
# One palette + one wallpaper drives colors and fonts everywhere that has a
# Stylix target: console, GRUB/boot, GTK/Qt, and — because home-manager runs as
# a NixOS module here — kitty, waybar, rofi, dunst, etc. for user `eugene` too.
#
# Swap the look by changing `base16Scheme` (browse: base16-schemes package) and
# `image` (any path/derivation that produces an image file).
{ pkgs, ... }:
{
  stylix = {
    enable = true;
    polarity = "dark";

    # Catppuccin Mocha. To use a different palette, point at another file under
    # ${pkgs.base16-schemes}/share/themes/ (e.g. gruvbox-dark-medium.yaml).
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

    # Wallpaper. Shipped with nixpkgs so no binary lives in this repo — replace
    # with your own: image = /persist/home/eugene/wallpapers/foo.png;
    image = pkgs.nixos-artwork.wallpapers.simple-dark-gray.gnomeFilePath;

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      sansSerif = {
        package = pkgs.noto-fonts;
        name = "Noto Sans";
      };
      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };
      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        terminal = 13;
        applications = 11;
      };
    };

    # Slight transparency for terminals/bars that support it.
    opacity.terminal = 0.95;
  };
}
