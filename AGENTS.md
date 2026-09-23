# AGENTS.md

This repository is a Nix configuration using the [Dendritic pattern](https://github.com/vic/dendritic): an aspect-oriented architecture where every Nix file is a module of a single top-level module evaluation (flake-parts), and each file implements one feature across all configuration classes it applies to.

## Architecture

- `flake.nix` is the only entry point. It contains only: inputs, the `mkFlake` bootstrap, and a single auto-import expression (`vic/import-tree ./modules`). No feature logic, no host definitions.
- Every other `.nix` file is a flake-parts module (a top-level module). A file is never "a NixOS module" or "a home-manager module" — it is always a top-level module that may *contribute* lower-level modules.
- Files under `modules/` are auto-imported by `import-tree`. Any path containing `/_` is ignored (the convention for disabling a module).
- Lower-level modules are stored via `flake.modules.<class>.<aspect>` (deferredModule merge semantics), where `<class>` is `nixos`, `homeManager`, `darwin`, etc. Multiple files may contribute to the same aspect name and merge.
- Hosts are declared inside top-level modules by composing aspects, e.g. `flake.nixosConfigurations.<host> = inputs.nixpkgs.lib.nixosSystem { modules = with config.flake.modules.nixos; [ ssh docker ]; }`.

## Rules

1. **Uniform module class** — every non-entry-point `.nix` file is a top-level (flake-parts) module of the same class.
2. **Feature-centric naming** — name files/directories after the feature (aspect) they implement, not after hosts, users, or configuration classes. Organize by *what* is configured, not *where*.
3. **Cross-class co-location** — all configuration for a feature, across every class it touches, lives in that one file (or its directory subtree). Never split a feature into `nixos/foo.nix` and `homeManager/foo.nix`.
4. **No manual imports of siblings** — never reference sibling modules by relative path in `imports`. Auto-import handles it. External flake inputs may be imported.
5. **No `specialArgs` / `extraSpecialArgs`** — share values between classes via file-scoped `let` bindings or top-level flake-parts options, not by injecting module arguments.
6. **Prefer `mkEnableOption`-style gating** — modules are imported but features are opted into; don't enable everything by default.
7. **Declare inputs where used** — flake inputs needed by a feature are declared in that feature's module (via `vic/flake-file`), keeping `flake.nix` minimal.

## Canonical example

```nix
# modules/ssh.nix -- a top-level module implementing the "ssh" aspect
{ inputs, ... }: let
  port = 2277; # shared across classes via let-binding
in {
  flake.modules.nixos.ssh = {
    services.openssh = { enable = true; inherit port; };
  };

  flake.modules.homeManager.ssh = {
    programs.ssh = { enable = true; extraConfig = "Port ${toString port}"; };
  };
}
```

## Commands

- **Verify changes**: `./scripts/verify.sh` (quick: `fmt` + `eval`), `./scripts/verify.sh all` (`fmt` + `eval` + `build` + `vm`). Works with nix or docker on any machine — see the Verification system section below.
- Format code: `./scripts/verify.sh --fix fmt` (canonical style: `nixfmt-rfc-style`).
- Build/eval a host: `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`
- Full check incl. building every check and running the VM tests: `nix flake check` (on non-NixOS hosts this needs `system-features = kvm nixos-test big-parallel` in nix.conf — `./scripts/verify.sh` handles that for you)
- Eval-only check: `nix flake check --no-build`
- Boot a host in an interactive QEMU VM: `nix run .#vm-<host>`
- Switch (on the target host): `sudo nixos-rebuild switch --flake .#<host>`

After any change, run `./scripts/verify.sh` (the `fmt` tier enforces canonical formatting); ensure verification passes before finishing.

**Important**: nix only sees files that are *tracked by git*. Run `git add -A` before verifying, otherwise new or renamed modules are silently ignored (the `eval`/`build`/`vm` tiers fail loudly if untracked `.nix` files exist).

## Verification system

The repo has a tiered verification system usable from **any machine — including one that does not run the OS this repo installs**. Nothing requires root or NixOS; you need either `nix` on PATH, or `docker` (the runner falls back to a persistent `nixos/nix` container automatically).

### Entry points

- `./scripts/verify.sh [tiers...]` — the main runner. Presets: `quick` (the default: `fmt eval`) and `all` (`fmt eval build vm`). Individual tiers can be combined freely.
- `./scripts/verify.sh --docker all` — force the Docker fallback.
- `./scripts/verify.sh --fix fmt` — apply formatting instead of checking it.
- `./scripts/verify.sh --clean` — remove the persistent verification container.
- `nix run .#verify` — the same runner exposed as a flake app (requires nix).
- `nix flake check` — CI-style: evaluates everything and *builds* every check, which includes running the VM tests (equivalent to the `all` preset, plus every other check).

### Tiers

| Tier  | What it proves                                             | How it runs                                                |
| ----- | ---------------------------------------------------------- | ---------------------------------------------------------- |
| `fmt`   | all `.nix` files are canonically formatted               | `nix fmt -- --check <files>` with `nixfmt-rfc-style`        |
| `eval`  | the whole flake (all outputs, all hosts) evaluates       | `nix flake check --no-build`                                |
| `build` | every host's full system closure builds                  | `nix build .#checks.<system>.toplevel-<host>`               |
| `vm`    | every host boots to a working multi-user system in a VM  | `nix build .#checks.<system>.vm-test-<host>` — building this check **runs** a NixOS test that boots the host headless in QEMU and asserts `multi-user.target`, `nixos-version`, etc. |

Tiers are cumulative: `eval` catches evaluation errors, `build` catches build failures, `vm` catches boot/runtime failures. Nothing here requires the target host's hardware — the VM tests compose the exact same host modules (`config.hosts`) that `nixosConfigurations` uses, with the NixOS test framework's VM plumbing layered on top.

### Docker fallback (no nix on the machine)

When `nix` is not on PATH, the runner creates a persistent privileged container (`nix-verify-<repo>`, image `nixos/nix`, override with `VERIFY_IMAGE`), mounts the repo at `/work`, and executes the tiers inside it with `docker exec`. The container — and its nix store — is reused across runs, so only the first run is slow. Details:

- `/dev/kvm` is passed through when available. Without it, VM tests fall back to slow software emulation (TCG) — they still pass, just slower.
- The image has no `git`, but the flake source is a git checkout, so `git` is provided via `nix shell <nixpkgs>#git` (cached in the container after first use).
- The container sets `system-features = kvm nixos-test big-parallel` so NixOS test derivations can be built.

### Where it lives

- `modules/verification.nix` — the flake-parts module exposing, per system:
  - `formatter.<system>` — `nixfmt-rfc-style`
  - `checks.<system>.toplevel-<host>` and `checks.<system>.vm-test-<host>` — one pair per entry in the top-level `hosts` option (declared in `modules/hosts.nix`; any module may read it or add hosts)
  - `packages.<system>.vm-<host>` — interactive VM runner (`nix run .#vm-<host>`)
  - `apps.<system>.verify` — wraps `scripts/verify.sh`
- `scripts/verify.sh` — the tier runner and Docker fallback (plain bash; readable/runnable without nix).

### Debugging a failing VM test

- Interactive python driver (poke at the booted VM): `nix run .#checks.<system>.vm-test-<host>.driver.interactive`, then e.g. `machine.succeed("systemctl status <unit>")`.
- Plain interactive VM with a console: `nix run .#vm-<host>`.
- Build logs: `nix build -L .#checks.<system>.vm-test-<host>`.

### Rules for agents

1. After **any** change: `git add -A`, then run `./scripts/verify.sh` (quick). Never report work as done while verification fails.
2. Before finishing: run `./scripts/verify.sh all`. At minimum `eval` + `build`; always include `vm` for changes affecting boot, filesystems, or enabled services.
3. If the `fmt` tier fails: `./scripts/verify.sh --fix fmt`, re-run verification.
4. When adding features that should be asserted at boot, extend the test script in `modules/verification.nix` (e.g. `machine.wait_for_unit("<service>.service")`).
5. New hosts: add an entry to the `hosts` option in `modules/hosts.nix` — it automatically gains `toplevel-*` and `vm-test-*` checks and a `vm-<host>` package.
