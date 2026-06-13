# Declarative secrets with sops-nix.
#
# Model: secrets live encrypted in git (secrets/secrets.yaml), decrypted at
# activation time into /run/secrets/* (tmpfs, never on disk). The decryption
# key is an age key DERIVED from this host's ed25519 SSH host key — which lives
# in /persist and survives the ephemeral-root wipe (see impermanence.nix).
#
# ── One-time setup ───────────────────────────────────────────────────────────
#   1. Derive the host's age public key from its SSH host key:
#        nix shell nixpkgs#ssh-to-age -c \
#          sh -c 'cat /persist/etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'
#   2. Put it in .sops.yaml at the repo root (see .sops.yaml.example).
#   3. Create the encrypted store (opens $EDITOR):
#        nix develop -c sops secrets/secrets.yaml
#   4. Uncomment `defaultSopsFile` and the example secret below, then rebuild.
#
# To also encrypt for your personal age key (so you can edit from anywhere),
# generate one with `age-keygen -o ~/.config/sops/age/keys.txt` and add its
# public key to .sops.yaml as well.
{ ... }:
{
  sops = {
    # The age key is auto-imported from the SSH host key — no separate key file.
    age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
    gnupg.sshKeyPaths = [ ]; # disable GPG path entirely

    # Uncomment once secrets/secrets.yaml exists (step 3 above):
    # defaultSopsFile = ../../secrets/secrets.yaml;

    # Example secret — uncomment to expose it at /run/secrets/example.
    # secrets.example = { };

    # Example: a user password hash consumed by users.users.<name>.hashedPasswordFile.
    # secrets."users/eugene" = {
    #   neededForUsers = true; # decrypted early, before users are created
    # };
  };
}
