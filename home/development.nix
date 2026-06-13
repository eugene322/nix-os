# Per-project dev environments via direnv + nix-direnv + devenv.
#
# Drop an `.envrc` into a project and the environment activates on cd:
#   • `use flake`   → a plain Nix flake devShell  (templates/flake/)
#   • `use devenv`  → a devenv.nix environment     (templates/devenv/)
# Copy a template to bootstrap:  cp -r ~/workspace/nix-os/templates/devenv/. .
{ pkgs, ... }:
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
    silent = true;
  };

  home.packages = [ pkgs.devenv ];
}
