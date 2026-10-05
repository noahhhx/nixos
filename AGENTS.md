# AGENTS.md

This repository is a Nix configuration built on the [Dendritic pattern](https://github.com/vic/dendritic). Every Nix file is a module of one top-level flake-parts evaluation, and each file implements one feature across all the configuration classes that feature touches.

## Architecture

- `flake.nix` is the only entry point. It holds the inputs and the `mkFlake` call, which imports `inputs.import-tree ./modules` and the flake-parts `modules` flake module. It holds no feature logic and no host definitions.
- Every other `.nix` file is a flake-parts module, called a top-level module. A file is never "a NixOS module" or "a home-manager module". It is a top-level module that can *contribute* lower-level modules.
- `import-tree` imports every file under `modules/`. It skips any path that contains `/_`. Use that prefix to disable a module or to keep a data file out of the evaluation.
- Lower-level modules live in `flake.modules.<class>.<aspect>`, where `<class>` is `nixos`, `homeManager`, or another configuration class. These options are deferred modules, so several files can contribute to one aspect and their contributions merge.
- A host is a set of aspects. `modules/hosts.nix` declares the `hosts` option, and each machine adds its entry from its own file under `modules/hosts/`, such as `hosts.myhost = { imports = [ config.flake.modules.nixos.desktop ]; };`.

## Layout

`modules/` is grouped by *domain*, never by configuration class. There is no `nixos/` directory next to a `homeManager/` directory. The comments name a few files in each directory, not all of them:

```
modules/
  systems.nix  hosts.nix  verification.nix   # flake plumbing: platforms, the host registry, and checks
  core/            # aspects every host builds on: base, boot, user, home-manager, secrets
  desktop/         # the graphical session: default.nix (the "desktop" bundle aspect), hyprland, waybar, kitty
  apps/            # standalone applications: git, zed, librewolf, zsh, pi
  hardware/        # hardware enablement: framework, audio, eoscam
  networking/      # network services: ssh, tailscale, mullvad
  virtualisation/  # docker
  hosts/           # one file per machine that sets hosts.<name>, plus _facts/ (per-install disk facts, see rule 8)
```

A bundle aspect such as `desktop` imports other aspects, so a host imports `desktop` instead of a dozen session aspects.

## Rules

1. **Use one module class.** Every `.nix` file except `flake.nix` is a top-level flake-parts module.
2. **Name files after features.** Name each file or directory after the aspect it implements, not after a host, a user, or a configuration class. Organize by *what* is configured, not *where*.
3. **Keep a feature in one place.** All configuration for a feature, in every class it touches, lives in one file or one directory. Never split a feature into `nixos/foo.nix` and `homeManager/foo.nix`.
4. **Never import siblings by path.** `import-tree` already imports every module, so no `imports` list names a sibling by relative path. Importing modules from flake inputs is fine. There is one exception. A host file imports its own install-facts file, `./_facts/<name>.nix`. That file is a plain NixOS data module, not an aspect, and its `/_` path keeps it out of `import-tree`.
5. **Don't use `specialArgs` or `extraSpecialArgs`.** To share a value between classes, use a `let` binding in the file or a top-level flake-parts option.
6. **Prefer `mkEnableOption`-style gating.** Modules are imported, but features are opted into. Don't enable everything by default.
7. **Declare inputs where you use them.** A feature declares the flake inputs it needs in its own module through `vic/flake-file`, which keeps `flake.nix` small.
8. **Never invent hardware facts.** Board enablement, such as the drivers, firmware, and quirks in `modules/hardware/framework.nix`, describes what a machine *is*. You can write it before the machine exists. Disk facts describe what an install *created*: partitioning, UUIDs, LUKS, swap layout, and the real bootloader. They must come from a real install, through the installer's `hardware-configuration.nix`, a [disko](https://github.com/nix-community/disko) declaration applied at install time, or [nixos-facter](https://github.com/nix-community/nixos-facter). Never invent disk facts or copy them from a previous OS. Until a real install exists, `modules/hosts/_facts/<name>.nix` holds placeholder disk config set with `mkDefault`. On the new machine, `./scripts/install.sh <name>` replaces that file with the installer's `/etc/nixos/hardware-configuration.nix`, unchanged. README.md has the steps.

## Canonical example

```nix
# A hypothetical modules/networking/sshd.nix that implements one aspect for two classes.
let
  port = 2277; # the let binding shares the port between both classes
in
{
  flake.modules.nixos.sshd = {
    services.openssh = {
      enable = true;
      ports = [ port ];
    };
  };

  flake.modules.homeManager.sshd = {
    programs.ssh = {
      enable = true;
      extraConfig = "Port ${toString port}";
    };
  };
}
```

## Commands

- Verify a change: `./scripts/verify.sh` runs `fmt` and `eval`. `./scripts/verify.sh all` adds `build` and `vm`. Both work with nix or docker on any machine. See [Verification system](#verification-system).
- Format code: `./scripts/verify.sh --fix fmt`. The canonical style is `nixfmt-rfc-style`.
- Build a host: `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`
- Build every check and run the VM tests: `nix flake check`. On a host that is not NixOS, nix.conf needs `system-features = kvm nixos-test big-parallel`. `./scripts/verify.sh` sets that for you.
- Evaluate without building: `nix flake check --no-build`
- Boot a host in an interactive QEMU VM: `nix run .#vm-<host>`
- Switch on the target host: `sudo nixos-rebuild switch --flake .#<host>`
- Adopt a fresh install on the target host: `./scripts/install.sh <host>`. It copies the installer's `hardware-configuration.nix` to `modules/hosts/_facts/<host>.nix`, commits it, and switches.

After any change, run `./scripts/verify.sh`, and finish only when it passes. The `fmt` tier enforces canonical formatting.

**Important**: nix sees only files that git tracks. Run `git add -A` before you verify. Otherwise nix ignores new and renamed modules without an error. The `eval`, `build`, and `vm` tiers fail if untracked `.nix` files exist.

## Verification system

`./scripts/verify.sh` runs tiered checks from **any machine, including one that does not run NixOS**. It needs no root. It needs `nix` on PATH or a running `docker`. Without nix, the runner moves into a persistent `nixos/nix` container.

### Entry points

- `./scripts/verify.sh [tiers...]` runs the given tiers. Two presets exist: `quick` (`fmt eval`, the default) and `all` (`fmt eval build vm`). You can combine individual tiers freely.
- `./scripts/verify.sh --docker all` forces the Docker fallback.
- `./scripts/verify.sh --fix fmt` applies formatting instead of checking it.
- `./scripts/verify.sh --clean` removes the persistent verification container.
- `nix run .#verify` runs the same script as a flake app. It requires nix.
- `nix flake check` evaluates everything and *builds* every check, which runs the VM tests. It covers the `all` preset plus every other check.

### Tiers

| Tier    | What it proves                                          | How it runs                                                  |
| ------- | ------------------------------------------------------- | ------------------------------------------------------------ |
| `fmt`   | every `.nix` file is canonically formatted              | `nix fmt -- --check <files>` with `nixfmt-rfc-style`         |
| `eval`  | the whole flake evaluates, including every host         | `nix flake check --no-build`                                 |
| `build` | every host's full system closure builds                 | `nix build .#checks.<system>.toplevel-<host>`                |
| `vm`    | every host boots and starts its services in a VM        | `nix build .#checks.<system>.vm-test-<host>`. Building this check **runs** a NixOS test that boots the host headless in QEMU. The test asserts `multi-user.target`, the greeter, home-manager, and the services the host enables. |

Each tier catches a later kind of failure: `eval` catches evaluation errors, `build` catches build failures, and `vm` catches boot and runtime failures. No tier needs the target host's hardware. The VM tests use the same host modules (`config.hosts`) as `nixosConfigurations` and add the NixOS test framework's VM config on top.

### Docker fallback

When `nix` is not on PATH, the runner creates a persistent privileged container named `nix-verify-<repo>` from the `nixos/nix` image. Set `VERIFY_IMAGE` to use another image. The runner mounts the repo at `/work` and runs the tiers inside the container with `docker exec`. Later runs reuse the container and its nix store, so only the first run is slow.

- The runner passes `/dev/kvm` through when it exists. Without it, VM tests use software emulation (TCG). They still pass, but slower.
- The image ships `git`. Nix needs it because the flake source is a git checkout.
- The container sets `system-features = kvm nixos-test big-parallel`, which nix needs to build NixOS test derivations.

### Where it lives

- `modules/verification.nix` is the flake-parts module that defines, per system:
  - `formatter.<system>`: `nixfmt-rfc-style`
  - `checks.<system>.toplevel-<host>` and `checks.<system>.vm-test-<host>`: one pair for each entry in the `hosts` option. `modules/hosts.nix` declares that option, and any module can read it or add hosts.
  - `packages.<system>.vm-<host>`: an interactive VM runner (`nix run .#vm-<host>`)
  - `apps.<system>.verify`: a wrapper around `scripts/verify.sh`
- `scripts/verify.sh` is the tier runner and the Docker fallback. It is plain bash, so you can read and run it without nix.

### Debug a failing VM test

- To run commands in the booted VM, start the interactive Python driver with `nix run .#checks.<system>.vm-test-<host>.driver.interactive`. Then call, for example, `machine.succeed("systemctl status <unit>")`.
- To get a plain VM with a console, run `nix run .#vm-<host>`.
- To see the build logs, run `nix build -L .#checks.<system>.vm-test-<host>`.

### Rules for agents

1. After **any** change, run `git add -A`, then `./scripts/verify.sh`. Never report work as done while verification fails.
2. Before you finish, run `./scripts/verify.sh all`. At minimum, run `eval` and `build`. If a change affects boot, filesystems, or enabled services, also run `vm`.
3. If the `fmt` tier fails, run `./scripts/verify.sh --fix fmt` and verify again.
4. To assert a new feature at boot, extend the test script in `modules/verification.nix`, for example with `machine.wait_for_unit("<service>.service")`.
5. To add a host, add a `modules/hosts/<name>.nix` file that sets `hosts.<name>`. The host gets `toplevel-*` and `vm-test-*` checks and a `vm-<host>` package with no further changes.
