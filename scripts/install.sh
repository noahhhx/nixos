#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${1:-https://github.com/<USER>/<REPO>.git}"
HOSTNAME="${2:-fw13}"
ROOT_MOUNT="/mnt"

echo "========================================"
echo " NixOS Automated Installer"
echo " Repo: $REPO_URL"
echo " Hostname: $HOSTNAME"
echo "========================================"

echo ""
echo "[1/3] Cloning configuration repo..."
git clone "$REPO_URL" "$ROOT_MOUNT/etc/nixos"

echo "[2/3] Generating hardware-configuration.nix..."
nixos-generate-config \
    --no-filesystems \
    --show-hardware-config \
    --root "$ROOT_MOUNT" \
    --dir "$ROOT_MOUNT/etc/nixos/hosts/$HOSTNAME"

echo "[3/3] Installing NixOS..."
nixos-install \
    --flake "$ROOT_MOUNT/etc/nixos#$HOSTNAME" \
    --no-root-passwd \
    --root "$ROOT_MOUNT"

echo ""
echo "========================================"
echo " Installation complete!"
echo " Reboot your system to use the new NixOS install."
echo "========================================"
echo ""
echo "After reboot, sync your config to git:"
echo "  cd /etc/nixos"
echo "  git add -A"
echo "  git commit -m 'Initial install'"
echo "  git push"