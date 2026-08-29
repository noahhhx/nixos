#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${1:-https://github.com/noahhhx/nixos.git}"
HOSTNAME="${2:-fw13}"
ROOT_MOUNT="/mnt"
REPO_PATH="${3:-}"

echo "========================================"
echo " NixOS Automated Installer"
echo " Hostname: $HOSTNAME"
echo " Root: $ROOT_MOUNT"
echo "========================================"

if [ -n "$REPO_PATH" ]; then
    echo ""
    echo "[1/3] Using existing repo at $REPO_PATH..."
    mkdir -p "$ROOT_MOUNT/etc/nixos/hosts/$HOSTNAME"
    cp -RL "$REPO_PATH"/. "$ROOT_MOUNT/etc/nixos/"
else
    echo ""
    echo "[1/3] Cloning configuration repo..."
    git clone "$REPO_URL" "$ROOT_MOUNT/etc/nixos"
fi

echo "[2/3] Generating hardware-configuration.nix..."
nixos-generate-config \
    --no-filesystems \
    --root "$ROOT_MOUNT" \
    --dir "$ROOT_MOUNT/etc/nixos/hosts/$HOSTNAME"

echo "[3/3] Installing NixOS..."
if [ -n "$REPO_PATH" ]; then
    nixos-install \
        --flake "path:$REPO_PATH#$HOSTNAME" \
        --no-root-passwd \
        --root "$ROOT_MOUNT"
else
    nixos-install \
        --flake "$ROOT_MOUNT/etc/nixos#$HOSTNAME" \
        --no-root-passwd \
        --root "$ROOT_MOUNT"
fi

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