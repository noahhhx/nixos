#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

say() { printf '\033[1m[install]\033[0m %s\n' "$*"; }
die() { printf '\033[1;31m[install]\033[0m %s\n' "$*" >&2; exit 1; }

host="${1:?usage: ./scripts/install.sh <host> (e.g. framework)}"
facts="modules/hosts/_facts/${host}.nix"
hw="/etc/nixos/hardware-configuration.nix"

[ -f "$facts" ] || die "unknown host '$host': no $facts in this repo"
[ -r "$hw" ] || die "cannot read $hw — run this on the machine you just installed"
command -v git >/dev/null 2>&1 || die "git not found — on a bare install run: nix-shell -p git"
git config user.email >/dev/null 2>&1 || die "git identity not set — run: git config --global user.email <you> && git config --global user.name <you>"

export NIX_CONFIG="experimental-features = nix-command flakes${NIX_CONFIG:+
$NIX_CONFIG}"

say "capturing install facts for host '$host'"
cp "$hw" "$facts"
nix fmt -- "$facts"
git add "$facts"
git commit -m "hosts/${host}: capture install facts from hardware-configuration.nix"
say "committed $facts (push it from a machine with your git credentials)"

say "switching to flake output #${host}"
sudo env NIX_CONFIG="$NIX_CONFIG" nixos-rebuild switch --flake "${REPO_ROOT}#${host}"
say "done — future updates: git pull && sudo nixos-rebuild switch --flake ${REPO_ROOT}#${host}"
