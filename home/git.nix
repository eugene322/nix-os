{ ... }:
{
  programs.git = {
    enable = true;
    userName = "Eugene";
    userEmail = "yevgeniy.batenev@gmail.com";

    delta = {
      enable = true;
      options = {
        navigate = true;
        side-by-side = true;
        line-numbers = true;
      };
    };

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      rerere.enabled = true;

      # SSH commit signing — enable once you have an SSH key and added the
      # public key as a signing key on GitHub/GitLab:
      # gpg.format = "ssh";
      # commit.gpgsign = true;
      # user.signingKey = "~/.ssh/id_ed25519.pub";
    };

    aliases = {
      st = "status -sb";
      lg = "log --oneline --graph --all";
      undo = "reset HEAD~1 --mixed";
    };
  };
}
