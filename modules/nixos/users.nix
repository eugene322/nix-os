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
    hashedPassword = "$6$Kfac.iXK5CCPMvFr$jKxYTqFhbDImFDZEMaTBL5j7h00gz1ED1j/fqiWOlpWY/Rgw721KvS9lOxBqrnh7Cw9SBUHOddwGJW/LwC75n.";

    # Later: manage declaratively via sops-nix (hashedPasswordFile = ...).
    # SSH key login (PasswordAuthentication is disabled in security.nix):
    # openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAA... you@host" ];
  };
}
