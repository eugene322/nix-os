# Home Manager root for user `eugene`. Imported from flake.nix.
{ pkgs, pkgs-unstable, ... }:
{
  imports = [
    ./shell.nix
    ./git.nix
    ./development.nix
    ./desktop.nix
  ];

  home = {
    username = "eugene";
    homeDirectory = "/home/eugene";
    stateVersion = "25.05";

    packages = with pkgs; [
      # CLI utilities
      bat
      fd
      ripgrep
      fzf
      eza
      jq
      tree
      btop
      wget
      curl
      unzip
      file
      lazygit
      gh # GitHub CLI
      brave
      helix
      jetbrains.rust-rover # Rust IDE (unfree; allowed via nixpkgs.config.allowUnfree)
      pkgs-unstable.claude-code # Latest unstable version
      pkgs-unstable.codex # Latest unstable version
    ];

    sessionVariables = {
      EDITOR = "hx";
      VISUAL = "hx";
      PAGER = "bat";
    };
  };

  programs.home-manager.enable = true;
  xdg.enable = true;
}
