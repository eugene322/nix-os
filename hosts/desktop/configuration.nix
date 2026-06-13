# Host: desktop.
#
# This file is intentionally thin — everything reusable lives in
# ../../modules/nixos. Only host-specific facts belong here.
{ ... }:
{
  imports = [
    ./disk-config.nix
    # Generate on the machine with:
    #   nixos-generate-config --no-filesystems --show-hardware-config \
    #     > hosts/desktop/hardware-configuration.nix
    # then uncomment. --no-filesystems is required so it doesn't clash with disko.
    # ./hardware-configuration.nix
    ../../modules/nixos
  ];

  networking.hostName = "desktop";

  # The release this host was first installed with. Do NOT bump on upgrade.
  system.stateVersion = "25.05";
}
