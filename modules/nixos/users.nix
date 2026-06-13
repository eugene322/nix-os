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

    # Set a password after first boot with `passwd`, or manage it declaratively
    # via sops-nix (users.users.eugene.hashedPasswordFile = ...).
    # SSH key login (PasswordAuthentication is disabled in security.nix):
    # openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAA... you@host" ];
  };
}
