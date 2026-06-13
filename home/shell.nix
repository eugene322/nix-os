# zsh + starship + zoxide + fzf.
{ ... }:
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;

    shellAliases = {
      ls = "eza --icons";
      ll = "eza -l --icons --git";
      la = "eza -la --icons --git";
      cat = "bat";
      g = "git";
      lg = "lazygit";

      # NixOS shortcuts (adjust the flake path if you move the repo).
      rebuild = "sudo nixos-rebuild switch --flake ~/workspace/nix-os#desktop";
      update = "cd ~/workspace/nix-os && nix flake update && rebuild";
      cleanup = "sudo nix-collect-garbage -d && sudo nixos-rebuild boot --flake ~/workspace/nix-os#desktop";
    };

    initContent = ''
      eval "$(zoxide init zsh)"
      bindkey '^R' fzf-history-widget
    '';
  };

  programs.starship.enable = true;
  programs.zoxide.enable = true;
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
