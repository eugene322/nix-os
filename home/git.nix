{ ... }:
{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Eugene";
        email = "25645669+eugene322@users.noreply.github.com";
      };

      alias = {
        st = "status -sb";
        lg = "log --oneline --graph --all";
        undo = "reset HEAD~1 --mixed";
      };

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
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = true;
      line-numbers = true;
    };
  };
}
