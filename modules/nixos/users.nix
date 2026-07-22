# Users. zsh is enabled system-wide; per-user shell config lives in home/.
{ pkgs, ... }:
{
  programs.zsh.enable = true;

  users.users.eugene = {
    isNormalUser = true;
    description = "Eugene";
    shell = pkgs.zsh;
    extraGroups = [
      "wheel" # sudo
      "networkmanager"
      "video"
      "audio"
      "input" # input devices (Wayland)
    ];

    # Ephemeral root: a password set via `passwd` will NOT survive a reboot.
    # Generate a hash with `mkpasswd -m sha-512` and paste it here BEFORE first boot.
    hashedPassword = "$6$0Uxc8hq.hExdMGZ8$sOaWQ6Y95IYsKx5wL0hdmh6xGXsViubhqT9d0rzBhpKz/JEOZ4cKrcj8w8ub7mBCXozUT8ccAqTLWNramcoKx0";

    # Later: manage declaratively via sops-nix (hashedPasswordFile = ...).
    # SSH key login (PasswordAuthentication is disabled in security.nix):
    # openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAA... you@host" ];
  };
}
