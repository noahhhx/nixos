# nixos

NixOS configuration using the [Dendritic pattern](https://github.com/vic/dendritic) — see [AGENTS.md](AGENTS.md) for the architecture and rules, including the verification system.

## Quick start

```console
$ ./scripts/verify.sh          # quick verification (formatting + evaluation)
$ ./scripts/verify.sh all      # full: also builds hosts and boots them in VMs
```

Works from any machine with `nix` **or** `docker` — you do not need to be running the OS this repo installs.
