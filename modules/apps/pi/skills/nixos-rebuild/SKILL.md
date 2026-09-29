---
name: nixos-rebuild
description: Build, verify, and switch noah's NixOS configuration from the flake repo at ~/nixos. Use for any task that edits system configuration, or asks to rebuild, switch, or test the OS setup.
---

# Working with the NixOS repo (`~/nixos`)

Read `~/nixos/AGENTS.md` first: the repo uses the dendritic pattern where every
`.nix` file under `modules/` is an auto-imported flake-parts module, features
live in `modules/<domain>/<feature>.nix`, and hosts are composed in
`modules/hosts/<name>.nix`. Only `flake.nix` is an entry point.

## Workflow

1. Edit files under `modules/` — never add manual sibling imports.
2. `cd ~/nixos && git add -A` — nix only sees *git-tracked* files, so new or
   renamed modules are silently ignored until added.
3. Verify: `./scripts/verify.sh` (fmt + eval). `./scripts/verify.sh all` also
   builds every host closure and runs the QEMU boot tests.
   Formatting fixes: `./scripts/verify.sh --fix fmt`.
4. Apply on the target machine: `sudo nixos-rebuild switch --flake ~/nixos#framework`.
5. Build/eval without switching: `nix build ~/nixos#nixosConfigurations.framework.config.system.build.toplevel`.
6. Boot the host in an interactive VM: `nix run ~/nixos#vm-framework`.

## Pi configuration

The `pi` CLI, the machine-specific instructions
(`modules/apps/pi/machine.md`) and skills (`modules/apps/pi/skills/<name>/`)
are managed by this repo; the portable setup (the global `AGENTS.md` base,
skills, extensions incl. pi-fff) by the `pi-shop` flake input
(`github:noahhhx/pi-shop`, locally `~/pi-shop`). Both land in `~/.pi/agent/`
via home-manager symlinks — don't edit files under `~/.pi/` directly (except
`settings.json`, `auth.json`, and sessions, which pi owns); change the
corresponding repo and rebuild.
