# Bootloader and kernel. UEFI + systemd-boot (simpler/faster than GRUB).
{ pkgs, ... }:
{
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10; # keep last N generations in the menu
      editor = false; # forbid editing kernel cmdline at boot (security)
    };
    efi.canTouchEfiVariables = true;
    timeout = 3;
  };

  # Latest kernel; drop to use the nixpkgs default LTS.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # /tmp is a persistent btrfs subvolume (@tmp) — wipe it on every boot so it
  # stays scratch-only. (Switch to boot.tmp.useTmpfs = true for RAM-backed /tmp,
  # in which case the @tmp subvolume in disk-config.nix becomes unnecessary.)
  boot.tmp.cleanOnBoot = true;
}
