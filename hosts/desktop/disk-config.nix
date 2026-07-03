# Disko disk layout for the "desktop" host.
#
# Layout (GPT):
#   1. ESP  — 1 GiB FAT32 EFI System Partition mounted at /boot
#   2. root — Btrfs (label "nixos") filling the rest, with subvolumes
#
# Btrfs with zstd compression + `noatime`, one subvolume per mount point:
#   @           /            system root
#   @home       /home        user data
#   @nix        /nix         the nix store (huge, kept separate)
#   @persist    /persist     state to keep across rebuilds (impermanence-ready)
#   @log        /var/log     logs (own subvolume so they don't pollute / snapshots)
#   @snapshots  /.snapshots  target for snapper / btrfs snapshots
#   @tmp        /tmp         scratch space
#   @swap       /swap        hosts the swapfile (CoW auto-disabled by disko)
#
# Usage:
#   - Set `device` to a *stable* path (prefer /dev/disk/by-id/...). Find it
#     with:  ls -l /dev/disk/by-id
#   - WARNING: running disko ERASES the target disk.
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/ata-KINGSTON_SA400S37480G_50026B728375797E";
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1; # ensure ESP is created before the 100% root part
              name = "ESP";
              size = "1G";
              type = "EF00"; # EFI System Partition
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "fmask=0077" "dmask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-L" "nixos" "-f" ]; # label + force
                subvolumes = {
                  "@"          = { mountpoint = "/";           mountOptions = [ "compress=zstd" "noatime" ]; };
                  "@home"      = { mountpoint = "/home";        mountOptions = [ "compress=zstd" "noatime" ]; };
                  "@nix"       = { mountpoint = "/nix";         mountOptions = [ "compress=zstd" "noatime" ]; };
                  "@persist"   = { mountpoint = "/persist";     mountOptions = [ "compress=zstd" "noatime" ]; };
                  "@log"       = { mountpoint = "/var/log";     mountOptions = [ "compress=zstd" "noatime" ]; };
                  "@snapshots" = { mountpoint = "/.snapshots";  mountOptions = [ "compress=zstd" "noatime" ]; };
                  "@tmp"       = { mountpoint = "/tmp";         mountOptions = [ "noatime" ]; };

                  # Swapfile on its own subvolume; CoW must be off for swap
                  # (disko handles disabling it). Size to taste / RAM.
                  "@swap" = {
                    mountpoint = "/swap";
                    swap.swapfile.size = "8G";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
