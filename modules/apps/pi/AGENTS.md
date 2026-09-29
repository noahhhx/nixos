# Global agent instructions

## Environment

- NixOS on a Framework Laptop 13 (AMD Ryzen AI 9 HX 370, x86_64, Zen 5
  cores + Radeon 890M iGPU, 12C/24T). All software is managed by Nix — never
  install packages with curl/pip/npm into the system; system changes go
  through the flake repo at `~/nixos`.
- The OS configuration, home-manager config, the `pi` CLI itself, its global
  `AGENTS.md` (this file), its skills, and its extensions are all versioned in
  that repo — see `modules/apps/pi/` there.
- zsh + carapace; editors: Zed, IntelliJ.
- Secrets are sops-encrypted; never write plaintext credentials into the repo
  or into command histories.

## Working on the system

For any task that changes system configuration (or asks to rebuild/switch),
use the `nixos-rebuild` skill: it covers the repo layout, verification tiers,
and the switch commands. Read `~/nixos/AGENTS.md` before editing anything in
that repo.

## Habits

- Make precise, minimal changes; leave formatting to the repo's canonical
  formatters rather than restyling untouched code.
- After editing a repo, run its verification/tests if any exist before
  reporting done; never claim success while checks fail.
