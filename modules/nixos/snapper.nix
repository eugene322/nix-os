# Btrfs snapshots via snapper.
#
# NOTE: with impermanence, / is ephemeral, so snapshotting it is pointless —
# we snapshot the subvolumes that actually hold state instead (/home, /persist).
# snapper stores them in <subvolume>/.snapshots automatically.
{ ... }:
let
  timeline = subvol: {
    SUBVOLUME = subvol;
    ALLOW_USERS = [ "eugene" ];
    TIMELINE_CREATE = true;
    TIMELINE_CLEANUP = true;
    TIMELINE_LIMIT_HOURLY = 5;
    TIMELINE_LIMIT_DAILY = 7;
    TIMELINE_LIMIT_WEEKLY = 4;
    TIMELINE_LIMIT_MONTHLY = 6;
    TIMELINE_LIMIT_YEARLY = 0;
  };
in
{
  services.snapper.configs = {
    home = timeline "/home";
    persist = timeline "/persist";
  };
}
