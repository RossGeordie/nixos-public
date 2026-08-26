# Weekly Nix profile-generation pruner + store garbage collector.
#
# NixOS 26.05 ships no "keep last N generations" option: nix.gc.automatic
# (services/misc/nix-gc.nix) only runs nix-collect-garbage on a schedule and
# never removes old profile generations, so /nix/store keeps every build.
#
# This module adds a one-shot service (weekly, Mon 04:05, Persistent so a
# missed slot fires on next boot) that:
#   1. trims system and per-user profile generations down to the last KEEP
#   2. runs `nix-collect-garbage -d` to free store paths nobody references.
#
# Set KEEP below to change the retention window. KEEP = 10 keeps 10 builds.
# NOTE: declared as a plain local value (not a custom module argument) —
# NixOS's _module.args machinery requires `_module.args.KEEP` to be set by
# some other module and does NOT honour a `? 10` default, so a custom-arg
# declaration breaks every eval with "attribute 'KEEP' missing".

{ ... }:

let
  # Change this to adjust retention (number of generations kept).
  KEEP = 10;
in
{
  systemd.services.nix-gc-prune = {
    description = "Nix: prune old profile generations + collect garbage";
    wantedBy = [ "multi-user.target" ];
    script = ''
      set -eu
      keep=${toString KEEP}
      trim() {
        p="$1"
        [ -d "$p" ] || return 0
        total=$(ls -1 "$p" | grep -Ec '^[a-z]+-[0-9]+-link$' || true)
        [ "$total" -ge 1 ] || return 0
        delete=$(( total - keep ))
        if [ "$delete" -gt 0 ]; then
          echo "$p: $total generations, deleting oldest $delete (keeping $keep)"
          nix-store --delete-generations "$p" "1-$delete"
        else
          echo "$p: keeping all $total generations (want $keep)"
        fi
      }
      trim /nix/var/nix/profiles/system
      for p in /nix/var/nix/profiles/per-user/*/home; do trim "$p"; done
      nix-collect-garbage -d
    '';
    serviceConfig = { Type = "oneshot"; };
  };

  systemd.timers.nix-gc-prune = {
    wantedBy = [ "timers.target" ];
    timerConfig = { OnCalendar = "Mon 04:05"; Persistent = true; };
  };
}
