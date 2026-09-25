#!/usr/bin/env bash
#
# Adopt a freshly installed machine into this repo, for one host.
#
# Usage (as a normal user, from the repo root, on the machine you just
# installed — see the "Fresh install" section of README.md):
#   ./scripts/install.sh <host>          # e.g. ./scripts/install.sh framework
#
# Requires: nix, sudo, and git (on a bare install: nix-shell -p git).
# Flakes are enabled per-invocation via NIX_CONFIG, so the fresh
# install needs no configuration changes.
#
# What it does:
#   1. copies /etc/nixos/hardware-configuration.nix verbatim to
#      modules/hosts/_facts/<host>.nix, replacing the placeholder
#   2. formats it (nixfmt-rfc-style) and commits it
#   3. switches the machine to the flake output #<host>
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
# nix evaluates only git-tracked files, so stage before formatting.
git add "$facts"
nix fmt -- "$facts"
git add "$facts"
git commit -m "hosts/${host}: capture install facts from hardware-configuration.nix"
say "committed $facts (push it from a machine with your git credentials)"

say "switching to flake output #${host}"
sudo env NIX_CONFIG="$NIX_CONFIG" nixos-rebuild switch --flake "${REPO_ROOT}#${host}"
say "done — future updates: git pull && sudo nixos-rebuild switch --flake ${REPO_ROOT}#${host}"
