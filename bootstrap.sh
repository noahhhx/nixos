#!/usr/bin/env bash
# bootstrap.sh — freshly ISO-installed NixOS box -> one of my machines.
# usage: sudo ./bootstrap.sh <vm|framework>
# Run AFTER a standard install from the installer ISO (graphical installer or
# console ceremony — either way the ISO owns partitioning and the base install),
# booted into that installed system. The script swaps the base system for OURS.
# Everything that must happen inside the target machine happens HERE — so that
# nobody ever edits files in a VM console (ground rule 2).
set -euo pipefail

host="${1:?usage: bootstrap.sh <vm|framework>}"
case "$host" in
  vm|framework) ;;
  *) echo "unknown host: $host" >&2; exit 1 ;;
esac
repo="$(cd "$(dirname "$0")" && pwd)"   # repo root, wherever it got cloned

[ "$(id -u)" = 0 ] || { echo "run me with sudo — I call nixos-rebuild switch."; exit 1; }

# The installer ISO has no /etc/nixos — that's the signature of still being on
# the ISO console instead of inside an installed system (Scar: the old
# partitioning script ran from the wrong side of that line and zapped a live
# disk before mkfs.fat noticed). The ISO install, then boot, THEN me.
[ -f /etc/nixos/hardware-configuration.nix ] || {
  echo "No /etc/nixos/hardware-configuration.nix — this is the installer ISO," >&2
  echo "not an installed system. Finish the ISO install, boot into it, run me there." >&2
  exit 1
}

# A stock ISO install does NOT enable flakes. nixos-rebuild shells out to nix,
# which reads NIX_CONFIG — one export covers the rebuild below.
export NIX_CONFIG="experimental-features = nix-command flakes"

# Hardware: both known hosts ship committed files describing the layout the ISO
# install is expected to create (VM: ESP /dev/vda1 + root /dev/vda2, virtio —
# device names follow the disk bus, see hardware/vm.nix). Fallback for a host
# without a committed file: the ISO installer already wrote ground truth to
# /etc/nixos/hardware-configuration.nix — copy it, never regenerate.
#   path: flake ref — clones are git trees and `.#host` sees only tracked
#   files; a fresh (untracked) hardware file needs the path: ref (Scar, Phase 3)
if [ ! -f "$repo/hardware/${host}.nix" ]; then
  cp /etc/nixos/hardware-configuration.nix "$repo/hardware/${host}.nix"
fi

# Sanity: if the committed hardware file doesn't know the disk we're actually
# booted from (LUKS? different bus? extra disks?), the install's layout doesn't
# match what the file promises — switching now would build a system that can't
# mount its own root. Refuse; fix the file on the host, push, pull, re-run.
root_dev="$(findmnt -no SOURCE /)"
grep -qF "$root_dev" "$repo/hardware/${host}.nix" || {
  echo "hardware/${host}.nix doesn't mention the device / is actually on ($root_dev)." >&2
  echo "The install's real layout doesn't match the committed file." >&2
  exit 1
}

nixos-rebuild switch --flake "path:${repo}#${host}"

echo "Done. Reboot to land clean in the real system."
echo "First boot is a bare TTY (no display manager yet): log in as noah (the"
echo "password you set during the ISO install, or 'changeme' if the account is"
echo "new), then run: uwsm start hyprland-uwsm.desktop"
echo "Then ssh in and never look back."
