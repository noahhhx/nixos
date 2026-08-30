#!/usr/bin/env bash
# bootstrap.sh — fresh NixOS box -> one of my machines.
# usage: sudo ./bootstrap.sh <vm|framework>
# Everything that must happen inside the target machine happens in HERE — so that
# nobody ever edits files in a VM console (ground rule 2).
set -euo pipefail

host="${1:?usage: bootstrap.sh <vm|framework>}"
root="/mnt"
repo="$(cd "$(dirname "$0")" && pwd)"   # repo root, wherever it got cloned

# The minimal installer ISO ships without gdisk (and possibly some mkfs tools).
# Scar #3: the ceremony died right here with "sgdisk: command not found". The fix
# is NOT a fourth pasted command in the console (ground rule 2) — the script
# provisions its own toolbox and re-execs itself with it in PATH.
# NOTE: the package is gptfdisk (it ships the sgdisk binary) — "gdisk" was
# renamed in nixpkgs; using the old attr name fails with "does not provide
# attribute packages.x86_64-linux.gdisk" (Scar #4).
if ! command -v sgdisk >/dev/null || ! command -v mkfs.fat >/dev/null || ! command -v mkfs.ext4 >/dev/null; then
  nix_bin="$(command -v nix || echo /run/current-system/sw/bin/nix)"
  exec "$nix_bin" shell nixpkgs#gptfdisk nixpkgs#dosfstools nixpkgs#e2fsprogs \
    --option experimental-features "nix-command flakes" \
    -c "$repo/bootstrap.sh" "$@"
fi

case "$host" in
  vm)
    # vm-curator attaches the disk over virtio, which Linux names /dev/vda.
    # Ground truth: ~/vm-space/<vm>/launch.sh — read its -drive line. A SATA bus
    # would name it /dev/sda; whatever the bus, hardware/vm.nix must agree.
    disk=/dev/vda
    [ -b "$disk" ] || { echo "$disk not found — run lsblk, fix the script on the host, push, re-clone."; exit 1; }
    if findmnt "$root" >/dev/null; then
      echo "$root is already mounted — fresh installs only."; exit 1
    fi
    # partition to EXACTLY match hardware/vm.nix (committed, deterministic)
    sgdisk --zap-all "$disk"
    sgdisk -n 1:0:+512M -t 1:ef00 "$disk"    # ESP  -> /boot
    sgdisk -n 2:0:0     -t 2:8300 "$disk"    # root -> /
    mkfs.fat -F32 "${disk}1"
    mkfs.ext4 -F "${disk}2"
    mount "${disk}2" "$root"
    mkdir -p "$root/boot" && mount "${disk}1" "$root/boot"
    ;;
  framework)
    # The Framework 13's SSD is NVMe: /dev/nvme0n1, partitions nvme0n1p1/p2.
    # Verify with lsblk (a USB stick will also appear — do NOT point me at it).
    disk=/dev/nvme0n1
    [ -b "$disk" ] || { echo "$disk not found — run lsblk, fix the script on the host, push, re-clone."; exit 1; }
    if findmnt "$root" >/dev/null; then
      echo "$root is already mounted — fresh installs only."; exit 1
    fi
    # real hardware, real data: this guard is the difference between a lab and a funeral
    read -rp "This WILL erase $disk. Type YES to continue: " answer
    [ "$answer" = "YES" ] || { echo "aborted, nothing was touched"; exit 1; }
    # partition to EXACTLY match hardware/framework.nix (committed, deterministic)
    sgdisk --zap-all "$disk"
    sgdisk -n 1:0:+1G -t 1:ef00 "$disk"      # ESP (roomy: fwupd puts EFI capsules here)
    sgdisk -n 2:0:0   -t 2:8300 "$disk"      # root -> /
    mkfs.fat -F32 "${disk}p1"
    mkfs.ext4 -F "${disk}p2"
    mount "${disk}p2" "$root"
    mkdir -p "$root/boot" && mount "${disk}p1" "$root/boot"
    ;;
  *) echo "unknown host: $host" >&2; exit 1 ;;
esac

# Hardware capture — a FALLBACK for machines whose hardware file isn't committed.
# Both known hosts ship committed, deterministic hardware files (the script's
# partitioning above is what makes hand-writing safe). If you ever add a host
# without one, three rules apply — each cost a real debugging session (Scars, Phase 3):
#   1. --root "$root"  — generate from the actual mounts, never the live ISO
#   2. --dir /tmp/hw   — generate-config ALSO writes a default configuration.nix;
#                        aimed at the repo, it clobbers your real one
#   3. path: flake ref — clones are git trees and `.#host` sees only tracked
#                        files; the fresh (untracked) hardware file needs path:
if [ ! -f "$repo/hardware/${host}.nix" ]; then
  nixos-generate-config --root "$root" --dir /tmp/hw
  cp /tmp/hw/hardware-configuration.nix "$repo/hardware/${host}.nix"
fi

nixos-install \
  --root "$root" \
  --flake "path:${repo}#${host}" \
  --no-root-passwd   # safe ONLY because users.nix sets initialPassword — verify it

echo "Done. Power off, detach the ISO, boot."
echo "First boot is a bare TTY (no display manager yet): log in with your user +"
echo "initialPassword, then run: uwsm start hyprland-uwsm.desktop"
echo "Then ssh in and never look back."
