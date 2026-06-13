# Impermanence: ephemeral root.
#
# The root subvolume (@) is reset to a pristine, empty snapshot (@-blank) on
# every boot, so the running system can never accumulate untracked state in /.
# Everything that must survive lives on its own subvolume (/home, /nix,
# /persist, /var/log) or is bind-mounted from /persist via the persistence
# block below.
#
# ONE-TIME SETUP (during install, right after running disko, while @ is still
# empty) — create the pristine snapshot the rollback restores from:
#
#   MNT=$(mktemp -d)
#   mount -o subvol=/ /dev/disk/by-label/nixos "$MNT"
#   btrfs subvolume snapshot -r "$MNT/@" "$MNT/@-blank"
#   umount "$MNT"
#
{ pkgs, ... }:
{
  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.services.rollback = {
    description = "Rollback btrfs root subvolume (@) to a pristine state";
    wantedBy = [ "initrd.target" ];
    after = [ "initrd-root-device.target" ];
    before = [ "sysroot.mount" ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    path = [ pkgs.btrfs-progs ];
    serviceConfig.ExecStart = pkgs.writeShellScript "btrfs-rollback" ''
      set -euo pipefail
      mkdir -p /btrfs_tmp
      mount -o subvol=/ /dev/disk/by-label/nixos /btrfs_tmp

      if [ -e /btrfs_tmp/@ ]; then
        # Delete nested subvolumes created by the running system first,
        # otherwise the parent subvolume cannot be removed.
        btrfs subvolume list -o /btrfs_tmp/@ | cut -f9 -d' ' | while read -r sub; do
          btrfs subvolume delete "/btrfs_tmp/$sub"
        done
        btrfs subvolume delete /btrfs_tmp/@
      fi

      btrfs subvolume snapshot /btrfs_tmp/@-blank /btrfs_tmp/@
      umount /btrfs_tmp
    '';
  };

  # /persist must be mounted early so bind-mounts below can resolve.
  fileSystems."/persist".neededForBoot = true;

  # What survives the wipe. Anything NOT listed here (and not on /home, /nix,
  # /var/log) is gone after a reboot — add to these lists as you find state
  # worth keeping.
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/lib/nixos" # stable uid/gid map — MUST persist or ownership breaks
      "/var/lib/systemd" # random seed, timers, coredumps
      "/etc/NetworkManager/system-connections" # saved Wi-Fi / connections
      "/var/lib/bluetooth"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
  };
}
