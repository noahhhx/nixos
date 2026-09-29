## Environment

- NixOS on a Framework Laptop 13 (AMD Ryzen AI 9 HX 370, x86_64, Zen 5
  cores + Radeon 890M iGPU, 12C/24T). All software is managed by Nix — never
  install packages with curl/pip/npm into the system; system changes go
  through the flake repo at `~/nixos`.
- The OS configuration, home-manager config, the `pi` CLI itself, and these
  machine-specific instructions and skills are versioned in `~/nixos` (see
  `modules/apps/pi/` there); the portable agent setup (the global AGENTS.md
  base, skills, extensions incl. pi-fff) comes from the `pi-shop` repository,
  consumed as a flake input.
- zsh + carapace; editors: Zed, IntelliJ.
- Secrets are sops-encrypted; never write plaintext credentials into the repo
  or into command histories.

## Working on the system

For any task that changes system configuration (or asks to rebuild/switch),
use the `nixos-rebuild` skill: it covers the repo layout, verification tiers,
and the switch commands. Read `~/nixos/AGENTS.md` before editing anything in
that repo.
