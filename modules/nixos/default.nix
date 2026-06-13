# Aggregates all reusable system modules. A host imports this directory and
# gets the whole baseline; comment out a line here to drop a feature for all
# hosts, or import individual modules per-host for finer control.
{
  imports = [
    ./nix.nix
    ./boot.nix
    ./networking.nix
    ./locale.nix
    ./users.nix
    ./security.nix
    ./secrets.nix # sops-nix scaffolding (secrets stay commented until set up)
    ./impermanence.nix
    ./snapper.nix
    ./stylix.nix # system-wide theming
    ./desktop.nix # Hyprland — swap for another module to change DE
    ./nvidia.nix # remove this import on AMD/Intel-only machines
  ];
}
