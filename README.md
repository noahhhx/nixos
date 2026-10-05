# nixos

My NixOS config, built on the [Dendritic pattern](https://github.com/vic/dendritic). Before you edit modules, read [AGENTS.md](AGENTS.md). It covers the architecture and the rules.

## Verify changes

`verify.sh` runs on any machine that has `nix` or `docker`:

```console
$ ./scripts/verify.sh        # check formatting and evaluate the flake
$ ./scripts/verify.sh all    # also build every host and boot each one in a VM
```

## Try it in a VM

```console
$ nix run .#vm-framework
$ nix run .#vm-default
```

The VM tests use the same host modules as the real machines. A passing VM test proves that the host boots, starts the greeter and its enabled services, and sets up the user's home. It does not test hardware drivers or the real disk layout.

## Adopt a fresh install

Each host keeps its install-specific disk facts (partitioning, UUIDs, LUKS, and the bootloader) in `modules/hosts/_facts/<host>.nix`. That file holds placeholders until a real install overwrites it.

1. Install NixOS from the graphical ISO. The defaults work. On a laptop, turn on LUKS.
2. Clone the repo on the new machine and run `install.sh`:
   ```console
   $ nix-shell -p git
   $ git clone git@github.com:noahhhx/nixos.git ~/nixos
   $ cd ~/nixos
   $ ./scripts/install.sh framework
   ```

`install.sh` copies `/etc/nixos/hardware-configuration.nix` to `modules/hosts/_facts/framework.nix` unchanged. It formats and commits the file, then switches to the `framework` host. The script turns on flakes for its own commands through `NIX_CONFIG`, so the fresh install needs no config changes first. The commit stays local. Push it from a machine that has your git credentials.

## Update inputs

```console
$ nix flake update                 # update every input
$ git add -A && ./scripts/verify.sh all
$ sudo nixos-rebuild boot --flake ~/nixos#framework   # takes effect at the next reboot
$ git commit flake.lock
```

Update about once a month and put each update in its own commit. A small update is easy to bisect.

## Roll back

Each rebuild creates a new generation, and the boot menu lists every generation that still exists:

```console
$ sudo nixos-rebuild switch --rollback     # switch to the previous generation
$ nixos-rebuild list-generations           # list all generations
```

`sudo nix-collect-garbage -d` deletes every old generation. Run it only after the current one has proven itself.

## Secrets

Hosts that import the `secrets` aspect decrypt sops-encrypted secrets with the age key at `/var/lib/sops-nix/key.txt`. The first activation generates that key, and nothing can regenerate it. After a reinstall, the host has a new key, so add its public key to the secrets file again.
