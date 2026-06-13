# Home Manager root for user `eugene`. Imported from flake.nix.
{ pkgs, ... }:
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
    ];

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "bat";
    };
  };

  programs.home-manager.enable = true;
  xdg.enable = true;
}
