# nixos

NixOS configuration using the [Dendritic pattern](https://github.com/vic/dendritic) — see [AGENTS.md](AGENTS.md) for the architecture and rules, including the verification system.

## Quick start

```console
$ ./scripts/verify.sh          # quick verification (formatting + evaluation)
$ ./scripts/verify.sh all      # full: also builds hosts and boots them in VMs
```

Works from any machine with `nix` **or** `docker` — you do not need to be running the OS this repo installs.

## Installing NixOS (graphical installer)

1. **Download** the *Graphical ISO image* (x86_64) from <https://nixos.org/download>.
2. **Write it to a USB stick**, e.g. from another Linux box:
   ```console
   $ lsblk                                     # identify the stick, e.g. /dev/sdz
   $ sudo dd if=nixos-*.iso of=/dev/sdz bs=4M oflag=direct status=progress
   ```
   (On Windows/macOS use [USBImager](https://gitlab.com/bztsrc/usbimager) or Rufus in DD mode.)
3. **Boot from the stick.** On the Framework 13: press `F12` for the boot menu (or `F2` for the BIOS setup). The NixOS ISO is not Secure Boot signed, so disable **Secure Boot** in the BIOS if it's enabled.
4. At the login screen pick the **NixOS** session (the live system), then open the **Install NixOS** installer (GNOME installer).
5. Go through the wizard:
   - Location / keyboard as you like.
   - **Partitioning**: the default *Erase disk* (GPT + EFI + ext4) is fine for a fresh machine. On the VM you can also just accept the defaults. Note which choices you make — the generated `hardware-configuration.nix` (next section) will reflect them.
   - Create your user.
6. **Install**, then reboot and remove the USB. You land on a plain, generic NixOS — the config from this repo replaces it next.

> In a VM (QEMU/virt-manager) skip the USB: attach the ISO, boot, and run the same installer. Use UEFI firmware if your hypervisor offers it, to match real hardware.

## Installing *this* configuration on the fresh install

The repo currently defines two hosts (registry in `modules/hosts.nix`, one file per machine in `modules/hosts/`): **`default`** (the VM-friendly sandbox, placeholder disk) and **`framework`** (this Framework 13 laptop, real disk layout). Both use the user `noah` (initial password `nixos` — change it with `passwd` after first login).

1. **Get git and the repo** (the fresh install has no git):
   ```console
   $ nix-shell -p git
   $ git clone <this-repo-url> ~/dev/nixos
   $ cd ~/dev/nixos
   ```
2. **Port the hardware config.** The installer wrote the *real* partitioning and boot setup to `/etc/nixos/hardware-configuration.nix`. For the framework host, diff it against the `hosts.framework` entry in `modules/hosts.nix` (which already carries this machine's disk layout) and update any UUIDs that changed. Keep the config in the repo so the machine is fully reproducible.
3. **Commit** — important: nix only sees git-*tracked* files, so `git add -A && git commit` before rebuilding, otherwise new/renamed modules are silently ignored.
4. **Switch** to this configuration — pick the host that matches the machine (`nixos-rebuild list-generations`-style host name from `modules/hosts.nix`):
   ```console
   $ sudo nixos-rebuild switch --flake ~/dev/nixos#framework   # the Framework 13 laptop
   $ sudo nixos-rebuild switch --flake ~/dev/nixos#default     # the VM-friendly sandbox host
   ```
   Reboot, log in as `noah`, set a real password, done — `/etc/nixos` is now dead weight; the flake is the source of truth.

> `nixos-rebuild test` does the same switch without setting it as the boot default — useful for trying changes you're not sure about.

## Trying things out in a VM first

Every host in this repo gets a VM runner and an automated boot test for free:

```console
$ nix run .#vm-framework                                # interactive VM (console login)
$ nix run .#vm-default                                  # ... same for the sandbox host
$ nix run .#checks.x86_64-linux.vm-test-framework.driver.interactive   # scripted test driver
$ ./scripts/verify.sh all                               # builds + boots all hosts headless
```

The VM tests use the *exact same* host modules as `nixosConfigurations` — the test plumbing transparently replaces the real disk config (`fileSystems`, LUKS, swap) with virtual disks — so anything that passes there (boots, reaches `multi-user.target`) will at least boot on real hardware too. Use this to try risky changes before touching the laptop.

## Doing updates

**How often**: monthly is a good cadence — `nix flake update` (optionally one input at a time), then `./scripts/verify.sh all` before switching. Don't let `flake.lock` sit for months: especially `nixos-hardware` moves quickly for young platforms like the Ryzen AI 300 board (kernel params, EC/audio quirks), and small regular bumps are much easier to bisect than rare big ones. Commit each bump separately so a regression maps to exactly one input change.

1. **Bump the inputs** (nixpkgs, home-manager, …) — they're pinned in `flake.lock`:
   ```console
   $ nix flake update                      # everything
   $ nix flake update nixpkgs              # just nixpkgs
   ```
2. **Verify before you switch** (from any machine, even a non-NixOS one):
   ```console
   $ git add -A && ./scripts/verify.sh     # add --docker if you have no nix; `all` to also build + VM-boot
   ```
3. **Apply**:
   ```console
   $ sudo nixos-rebuild boot --flake ~/dev/nixos#default   # applies at next reboot (recommended)
   # or immediately:
   $ sudo nixos-rebuild switch --flake ~/dev/nixos#default
   ```
4. **Commit the updated `flake.lock`** — that commit *is* your pinned, reproducible system state. (Then `git push`, so the repo and the machine can't drift apart.)

## Secrets

Hosts that import the `secrets` aspect (`modules/core/secrets.nix`, currently the framework host) decrypt sops-encrypted secrets from a per-host age key in `/var/lib/sops-nix/key.txt` (generated automatically on first activation) — no plaintext in the repo, no key management beyond it. Bootstrap recipe and usage are documented at the top of that module; in short:

```console
$ sudo nix shell nixpkgs#age -- age-keygen -y /var/lib/sops-nix/key.txt  # this host's age pubkey
$ nix shell nixpkgs#sops -- sops --age age1... modules/core/secrets.yaml # create/edit secrets
```

then reference them as `sops.secrets.<name>.path` in configuration. The encrypted file must be git-tracked.

## Reverting

Every `nixos-rebuild` creates a **generation** — a complete, bootable snapshot. Nothing is ever lost by updating.

- **One step back** (previous generation, including the flake packages that built it):
  ```console
  $ sudo nixos-rebuild switch --rollback
  ```
- **Any generation**: the boot menu (GRUB/systemd-boot) lists recent generations — pick one at boot. To see what exists:
  ```console
  $ nixos-rebuild list-generations
  ```
- **Back to a specific repo state**: check out an older commit (i.e. an older `flake.lock`) and rebuild:
  ```console
  $ git checkout <older-commit>
  $ sudo nixos-rebuild switch --flake .#default
  ```
- Rollbacks restore the *system* (services, packages, home-manager modules). They do not roll back data in `$HOME` or the repo itself.
- Old generations keep disk space alive; clean them out once you're happy:
  ```console
  $ sudo nix-collect-garbage -d
  ```

## The Framework 13 (AMD) host

The `framework` host (`modules/hosts.nix`) is already defined for the Framework Laptop 13 with the AMD Ryzen AI 300 series board, composed from the same aspects as `default` plus:

- **`framework` aspect** (`modules/hardware/framework.nix`) — Radeon 890M graphics (mesa + early KMS for the 2256x1504 panel), NetworkManager + Bluetooth for the MT7925 WiFi 7 chip (in-tree driver, no out-of-tree firmware needed), firmware updates via LVFS (`fwupdmgr`), and full-RAM zstd zram swap. The fingerprint reader is deliberately unused (plain passwords).
- **`audio` aspect** (`modules/hardware/audio.nix`) — the PipeWire stack.
- **The real disk layout** — systemd-boot on a 2G ESP, LUKS2 root, btrfs subvolumes (`@`, `@home`, `@log`, `@pkg`) with zstd compression, matching this machine's current partitioning. The UUIDs were captured from the existing install; **if you reinstall from scratch, update them from the installer-generated `/etc/nixos/hardware-configuration.nix`.**

To apply it on the laptop:

```console
$ git add -A && ./scripts/verify.sh all        # proves the host builds & boots in a VM
$ sudo nixos-rebuild switch --flake ~/dev/nixos#framework
```

The `default` host stays as the VM-friendly sandbox, so the two machines share all aspects but keep their hardware specifics separate. When adding hardware-specific tweaks for another machine, prefer a new aspect file (like `framework.nix`) plus a new host entry, rather than growing `default`.
