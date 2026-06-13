# Security baseline.
{ ... }:
{
  # wheel still needs a password for sudo (default, kept explicit).
  security.sudo.wheelNeedsPassword = true;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      # Key-only auth. Add your key in modules/nixos/users.nix
      # (users.users.eugene.openssh.authorizedKeys.keys) BEFORE relying on this,
      # or you can lock yourself out of remote access.
      PasswordAuthentication = false;
    };
  };
}
