---
name: nixos-rebuild
description: Build, verify, and switch noah's NixOS configuration from the flake repo at ~/nixos. Use for any task that edits the system configuration or asks to rebuild, switch, or test the OS setup.
---

# Change the NixOS configuration in `~/nixos`

Read `~/nixos/AGENTS.md` first. The repo uses the Dendritic pattern. Every `.nix` file under `modules/` is a flake-parts module that `import-tree` imports. Features live in `modules/<domain>/<feature>.nix`, and each host is composed in `modules/hosts/<name>.nix`. `flake.nix` is the only entry point.

## Workflow

1. Edit files under `modules/`. Never import a sibling module by path.
2. Run `cd ~/nixos && git add -A`. Nix sees only files that git tracks, so it ignores new and renamed modules until you add them.
3. Run `./scripts/verify.sh` to check formatting and evaluation. `./scripts/verify.sh all` also builds every host and runs the QEMU boot tests. If formatting fails, run `./scripts/verify.sh --fix fmt`.
4. To apply the change on this machine, run `sudo nixos-rebuild switch --flake ~/nixos#framework`.

To build the system without switching, run `nix build ~/nixos#nixosConfigurations.framework.config.system.build.toplevel`. To boot the host in an interactive VM, run `nix run ~/nixos#vm-framework`.

## Pi configuration

This repo manages the `pi` CLI, the machine-specific instructions in `modules/apps/pi/machine.md`, and the skills in `modules/apps/pi/skills/<name>/`. The `pi-shop` flake input (`github:noahhhx/pi-shop`, checked out at `~/pi-shop`) manages the portable setup: the global `AGENTS.md` base, skills, and extensions such as pi-fff.

Home-manager links files from both repos into `~/.pi/agent/`. Don't edit files under `~/.pi/` directly. Change the repo that owns the file and rebuild. Pi itself owns `settings.json`, `auth.json`, and the sessions, so you can edit those in place.
