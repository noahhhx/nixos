#!/usr/bin/env bash
set -euo pipefail

HOSTNAME="${2:-fw13}"
ROOT_MOUNT="/mnt"
REPO_PATH="${3:-}"

echo "========================================"
echo " NixOS Automated Installer"
echo " Hostname: $HOSTNAME"
echo " Root: $ROOT_MOUNT"
echo "========================================"

echo "[2/3] Generating hardware-configuration.nix..."
nixos-generate-config \
    --no-filesystems \
    --root "$ROOT_MOUNT" \
    --dir "../hosts/$HOSTNAME"


nixos-install \
    --flake "path:$REPO_PATH#$HOSTNAME" \
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