#!/usr/bin/env bash
set -euo pipefail

HOSTNAME="${1:-fw13}"
ROOT_MOUNT="/mnt"
REPO_PATH="${2:-.}"
REPO_PATH="$(readlink -f "$REPO_PATH")"

echo "========================================"
echo " NixOS Automated Installer"
echo " Hostname: $HOSTNAME"
echo " Root: $ROOT_MOUNT"
echo " Repo: $REPO_PATH"
echo "========================================"

echo "[1/2] Generating hardware-configuration.nix..."
nixos-generate-config \
    --dir "$REPO_PATH/hosts/$HOSTNAME"

echo "[2/2] Installing NixOS..."
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