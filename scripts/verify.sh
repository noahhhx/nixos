#!/usr/bin/env bash
#
# Tiered verification for this NixOS flake.
#
# Runs on any machine, including one that does not run NixOS. It needs `nix`
# on PATH or a running Docker. Without nix, it runs every tier inside a
# persistent nixos/nix container. Later runs reuse the container and its nix
# store, so only the first run is slow.
#
# Usage:
#   ./scripts/verify.sh                quick preset (default): fmt + eval
#   ./scripts/verify.sh all            full: fmt + eval + build + vm
#   ./scripts/verify.sh <tier>...      any combination of: fmt eval build vm
#   ./scripts/verify.sh --fix fmt      apply formatting instead of checking
#   ./scripts/verify.sh --docker all   force the Docker fallback
#   ./scripts/verify.sh --clean        delete the persistent Docker container
#
# Tiers:
#   fmt    all .nix files are canonically formatted (nixfmt-rfc-style)
#   eval   the whole flake evaluates (nix flake check --no-build)
#   build  every host's system closure builds (checks.<sys>.toplevel-<host>)
#   vm     every host boots and starts its services in a headless QEMU VM
#          (checks.<sys>.vm-test-<host>. Building the check runs the test.)
#
# Environment overrides:
#   VERIFY_IMAGE      docker image to use            (default: nixos/nix)
#   VERIFY_CONTAINER  container name                 (default: nix-verify-<repo>)
#
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

IMAGE="${VERIFY_IMAGE:-nixos/nix}"
REPO_NAME="$(basename "$REPO_ROOT" | tr -cd 'A-Za-z0-9-')"
CONTAINER="${VERIFY_CONTAINER:-nix-verify-${REPO_NAME:-repo}}"

say() { printf '\033[1m[verify]\033[0m %s\n' "$*"; }
pass() { printf '\033[1;32m[verify]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[verify]\033[0m %s\n' "$*"; }
die() { printf '\033[1;31m[verify]\033[0m %s\n' "$*" >&2; exit 1; }
banner() { printf '\n\033[1;35m==> tier: %s\033[0m\n' "$*"; }

usage() { sed -n '2,/^set /{/^#/p}' "$0" | sed 's/^# \{0,1\}//'; }

clean_docker() {
  if docker rm -f "$CONTAINER" >/dev/null 2>&1; then
    say "removed verification container '$CONTAINER'"
  else
    say "no verification container to remove"
  fi
}


MODE="auto"
FIX=0
TIERS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --docker) MODE="docker"; shift ;;
    --fix) FIX=1; shift ;;
    --clean) clean_docker; exit 0 ;;
    -h | --help) usage; exit 0 ;;
    quick) TIERS+=(fmt eval); shift ;;
    all) TIERS+=(fmt eval build vm); shift ;;
    fmt | eval | build | vm) TIERS+=("$1"); shift ;;
    *) die "unknown argument: $1 (try --help)" ;;
  esac
done
[ "${#TIERS[@]}" -gt 0 ] || TIERS+=(fmt eval)


have_nix() { command -v nix >/dev/null 2>&1; }
have_docker() { command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; }

DOCKER=0
if [ "$MODE" = "docker" ]; then
  DOCKER=1
elif ! have_nix; then
  have_docker || die "neither nix nor docker is available; install one of them"
  say "nix is not on PATH, so using the Docker fallback"
  DOCKER=1
fi
if (( DOCKER )) && ! have_docker; then
  die "--docker was given, but docker is not installed or not running"
fi

ensure_container() {
  docker container inspect "$CONTAINER" >/dev/null 2>&1 && return 0
  say "creating verification container '$CONTAINER' (reused across runs)..."
  local args=(
    -d --name "$CONTAINER" --privileged
    -e NIX_CONFIG=$'experimental-features = nix-command flakes\nsystem-features = kvm nixos-test big-parallel'
    -v "$REPO_ROOT:/work"
  )
  [ -e /dev/kvm ] && args+=(--device /dev/kvm)
  docker run "${args[@]}" "$IMAGE" sleep infinity >/dev/null
  # The repo is mounted from the host and owned by a different uid than the
  # container's root, so git (and nix's libgit2) need this exemption.
  docker exec "$CONTAINER" git config --global --add safe.directory /work >/dev/null
}

run() {
  if (( DOCKER )); then
    ensure_container
    docker exec -w /work "$CONTAINER" "$@"
  else
    "$@"
  fi
}


ensure_lock() {
  if [ ! -e flake.lock ]; then
    say "no flake.lock, so creating one. Commit it."
    run nix flake lock
  fi
}

check_untracked() {
  run git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    warn "not a git work tree. Nix may not see every file."
    return 0
  }
  local untracked
  untracked="$(run git ls-files --others --exclude-standard -- '*.nix' || true)"
  if [ -n "$untracked" ]; then
    die "nix sees only files that git tracks, so it ignores these untracked .nix files:
$untracked
To fix this, run git add -A, then run ./scripts/verify.sh again."
  fi
}

list_hosts() {
  run nix eval --raw .#nixosConfigurations --apply 'a: builtins.concatStringsSep " " (builtins.attrNames a)'
}

list_check_systems() {
  run nix eval --raw .#checks --apply 'a: builtins.concatStringsSep " " (builtins.attrNames a)'
}


tier_fmt() {
  banner fmt
  local files
  files="$(find . -name '*.nix' -not -path './.git/*' | sort | tr '\n' ' ')"
  [ -n "$files" ] || die "no .nix files found (repo moved?)"
  ensure_lock
  if (( FIX )); then
    run nix fmt -- $files
    pass "formatted (nixfmt-rfc-style)"
  else
    if run nix fmt -- --check $files; then
      pass "formatting ok (nixfmt-rfc-style)"
    else
      die "some files are not formatted. To fix them, run ./scripts/verify.sh --fix fmt"
    fi
  fi
}

tier_eval() {
  banner eval
  ensure_lock
  check_untracked
  run nix flake check --no-build
  pass "flake evaluates cleanly (all outputs, all hosts)"
}

tier_build() {
  banner build
  ensure_lock
  check_untracked
  local systems hosts h s
  hosts="$(list_hosts)"
  systems="$(list_check_systems)"
  for s in $systems; do
    for h in $hosts; do
      say "building system closure: host '$h' ($s)"
      run nix build --no-link --print-out-paths ".#checks.$s.toplevel-$h"
      pass "host '$h' ($s): system toplevel builds"
    done
  done
}

tier_vm() {
  banner vm
  ensure_lock
  check_untracked
  if [ ! -e /dev/kvm ]; then
    warn "no /dev/kvm, so VM tests use TCG software emulation. The results are still valid, but slower."
  fi
  local systems hosts h s
  hosts="$(list_hosts)"
  systems="$(list_check_systems)"
  for s in $systems; do
    for h in $hosts; do
      say "vm-test: booting host '$h' ($s) in headless QEMU"
      if (( DOCKER )); then
        run nix build --no-link --print-out-paths ".#checks.$s.vm-test-$h"
      else
        NIX_CONFIG="${NIX_CONFIG:+${NIX_CONFIG}
}system-features = kvm nixos-test big-parallel" \
          nix build --no-link --print-out-paths ".#checks.$s.vm-test-$h"
      fi
      pass "vm-test: host '$h' booted and passed its checks"
    done
  done
}


main() {
  local t
  for t in "${TIERS[@]}"; do
    case "$t" in
      fmt) tier_fmt ;;
      eval) tier_eval ;;
      build) tier_build ;;
      vm) tier_vm ;;
    esac
  done
  printf '\n'
  pass "verification passed: ${TIERS[*]}"
}

main
