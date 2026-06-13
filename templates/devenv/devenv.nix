# devenv environment. Docs: https://devenv.sh
# Activate with `.envrc` containing `use devenv` + `direnv allow`.
{ pkgs, ... }:
{
  # Packages available in the shell.
  packages = [ pkgs.git ];

  # Pick the languages you need (uncomment):
  # languages.rust.enable = true;
  # languages.python.enable = true;
  # languages.javascript.enable = true;
  # languages.go.enable = true;

  # Environment variables.
  # env.GREET = "devenv";

  # Convenience scripts: run `devenv shell <name>` or just `<name>` in-shell.
  # scripts.hello.exec = "echo hello from $GREET";

  # Processes started by `devenv up`.
  # processes.ping.exec = "ping example.com";

  # Git hooks. Docs: https://devenv.sh/git-hooks/
  # git-hooks.hooks.nixfmt-rfc-style.enable = true;
}
