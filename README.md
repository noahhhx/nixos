# nixos

My NixOS config, using the [Dendritic pattern](https://github.com/vic/dendritic). The architecture and rules live in [AGENTS.md](AGENTS.md) — read that if you're editing modules.

## Verify changes

Works from any machine with `nix` or `docker`:

```console
$ ./scripts/verify.sh        # format + eval check
$ ./scripts/verify.sh all    # also builds and VM-boots every host
```

## Try it in a VM

```console
$ nix run .#vm-framework     # interactive VM
$ nix run .#vm-default
```

VM tests use the exact same host config as the real machines — if it boots in the VM, it should boot on hardware.

## Fresh install → this config

1. Install NixOS with the graphical ISO (defaults are fine; enable LUKS on a real laptop).
2. Get the repo on the new machine:
   ```console
   $ nix-shell -p git
   $ git clone <repo-url> ~/dev/nixos
   $ cd ~/dev/nixos
   ```
3. Copy the real disk/boot config from `/etc/nixos/hardware-configuration.nix` into `modules/hosts/framework.nix` (replacing the placeholder), then commit — nix only sees git-tracked files.
4. Switch:
   ```console
   $ sudo nixos-rebuild switch --flake ~/dev/nixos#framework
   ```

## Updates

```console
$ nix flake update                 # bump inputs
$ git add -A && ./scripts/verify.sh all
$ sudo nixos-rebuild boot --flake ~/dev/nixos#framework   # applies at next reboot
$ git commit flake.lock
```

Bump roughly monthly, one bump per commit — small bumps are easy to bisect.

## Reverting

Nothing is ever lost — every rebuild is a bootable snapshot:

```console
$ sudo nixos-rebuild switch --rollback     # one step back
$ nixos-rebuild list-generations           # see all of them (boot menu picks any)
```

Clean up old generations once you're happy: `sudo nix-collect-garbage -d`.

## Secrets

Hosts with the `secrets` aspect decrypt sops-encrypted secrets using a key at `/var/lib/sops-nix/key.txt`. See the top of `modules/core/secrets.nix` for how to add one.
