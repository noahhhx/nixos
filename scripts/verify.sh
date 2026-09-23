#!/usr/bin/env bash
#
# Tiered verification for this NixOS flake.
#
# Usable from ANY machine — including one that does not run the OS this repo
# installs. Requirements: either `nix` on PATH, or Docker (the script then
# runs all tiers inside a persistent nixos/nix container; the container and
# its nix store are reused across runs, so only the first run is slow).
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
#   vm     every host boots to multi-user.target in a headless QEMU VM
#          (checks.<sys>.vm-test-<host>; building the check runs the test)
#
# Environment overrides:
#   VERIFY_IMAGE      docker image to use            (default: nixos/nix)
#   VERIFY_CONTAINER  container name                 (default: nix-verify-<repo>)
#   VERIFY_GIT_REF    nixpkgs ref used to provide git in the container
#
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

IMAGE="${VERIFY_IMAGE:-nixos/nix}"
REPO_NAME="$(basename "$REPO_ROOT" | tr -cd 'A-Za-z0-9-')"
CONTAINER="${VERIFY_CONTAINER:-nix-verify-${REPO_NAME:-repo}}"
# The nixos/nix image has no git, but the flake source is a git checkout;
# git is provided via nix shell (cached in the container after first use).
GIT_REF="${VERIFY_GIT_REF:-github:NixOS/nixpkgs/nixos-25.05}"

say() { printf '\033[1m[verify]\033[0m %s\n' "$*"; }
pass() { printf '\033[1;32m[verify]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[verify]\033[0m %s\n' "$*"; }
die() { printf '\033[1;31m[verify]\033[0m %s\n' "$*" >&2; exit 1; }
banner() { printf '\n\033[1;35m==> tier: %s\033[0m\n' "$*"; }

usage() { sed -n '2,22p' "$0" | sed 's/^# \{0,1\}//'; }

clean_docker() {
  if docker rm -f "$CONTAINER" >/dev/null 2>&1; then
    say "removed verification container '$CONTAINER'"
  else
    say "no verification container to remove"
  fi
}

# --- argument parsing --------------------------------------------------------

MODE="auto" # auto | docker
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

# --- environment selection ---------------------------------------------------

have_nix() { command -v nix >/dev/null 2>&1; }
have_docker() { command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; }

DOCKER=0
if [ "$MODE" = "docker" ]; then
  DOCKER=1
elif ! have_nix; then
  have_docker || die "neither nix nor docker is available; install one of them"
  say "nix not found on PATH — using the Docker fallback"
  DOCKER=1
fi
if (( DOCKER )) && ! have_docker; then
  die "docker requested but not available/running"
fi

ensure_container() {
  docker container inspect "$CONTAINER" >/dev/null 2>&1 && return 0
  say "creating verification container '$CONTAINER' (reused across runs)..."
  local args=(
    -d --name "$CONTAINER" --privileged
    -e NIX_CONFIG=$'experimental-features = nix-command flakes\nsystem-features = kvm nixos-test big-parallel'
    -v "$REPO_ROOT:/work"
  )
  # Give the container KVM when the host has it; otherwise VM tests fall
  # back to slow software emulation (TCG) but still run.
  [ -e /dev/kvm ] && args+=(--device /dev/kvm)
  docker run "${args[@]}" "$IMAGE" sleep infinity >/dev/null
  # The repo is mounted from the host and owned by a different uid than the
  # container's root, so git (and nix's libgit2) need this exemption.
  docker exec "$CONTAINER" nix shell "$GIT_REF#git" -c \
    git config --global --add safe.directory /work >/dev/null
}

# run <cmd...> — run a command with nix (and git) available.
run() {
  if (( DOCKER )); then
    ensure_container
    docker exec -w /work "$CONTAINER" nix shell "$GIT_REF#git" -c "$@"
  else
    "$@"
  fi
}

# --- helpers ------------------------------------------------------------------

ensure_lock() {
  if [ ! -e flake.lock ]; then
    say "no flake.lock — creating one (commit it)"
    run nix flake lock
  fi
}

# Nix sees only git-tracked files; fail early if new .nix files are invisible.
check_untracked() {
  run git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    warn "not a git work tree — nix may not see all files"
    return 0
  }
  local untracked
  untracked="$(run git ls-files --others --exclude-standard -- '*.nix' || true)"
  if [ -n "$untracked" ]; then
    die "untracked .nix files are INVISIBLE to the flake (nix only sees git-tracked files):
$untracked
Fix: git add -A, then re-run ./scripts/verify.sh"
  fi
}

list_hosts() {
  run nix eval --raw .#nixosConfigurations --apply 'a: builtins.concatStringsSep " " (builtins.attrNames a)'
}

list_check_systems() {
  run nix eval --raw .#checks --apply 'a: builtins.concatStringsSep " " (builtins.attrNames a)'
}

# --- tiers --------------------------------------------------------------------

tier_fmt() {
  banner fmt
  local files
  files="$(find . -name '*.nix' -not -path './.git/*' | sort | tr '\n' ' ')"
  [ -n "$files" ] || die "no .nix files found (repo moved?)"
  ensure_lock
  if (( FIX )); then
    # shellcheck disable=SC2086
    run nix fmt -- $files
    pass "formatted (nixfmt-rfc-style)"
  else
    # shellcheck disable=SC2086
    if run nix fmt -- --check $files; then
      pass "formatting ok (nixfmt-rfc-style)"
    else
      die "formatting mismatch — fix with: ./scripts/verify.sh --fix fmt"
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
    warn "/dev/kvm not found — VM tests run under slow TCG emulation (still valid, just slow)"
  fi
  local systems hosts h s
  hosts="$(list_hosts)"
  systems="$(list_check_systems)"
  for s in $systems; do
    for h in $hosts; do
      say "vm-test: host '$h' ($s) — headless QEMU boot, asserts multi-user.target"
      if (( DOCKER )); then
        run nix build --no-link --print-out-paths ".#checks.$s.vm-test-$h"
      else
        # NixOS tests declare requiredSystemFeatures = [ "kvm" ]; make sure
        # this machine is allowed to build them (TCG fallback if no /dev/kvm).
        NIX_CONFIG="system-features = kvm nixos-test big-parallel" \
          nix build --no-link --print-out-paths ".#checks.$s.vm-test-$h"
      fi
      pass "vm-test: host '$h' boots and reaches multi-user.target"
    done
  done
}

# --- main ---------------------------------------------------------------------

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
