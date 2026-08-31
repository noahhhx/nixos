# nixos

My NixOS + home-manager config, structured [dendritically](https://github.com/mightyiam/dendritic):
every Nix file under `modules/` is a top-level module, a file's path names a
feature, and a feature spans **all** configuration classes (NixOS *and*
home-manager) that it applies to. `flake.nix` is just inputs; everything else
lives in the tree.

```
├── flake.nix             # entry point: inputs + auto-import of ./modules
├── flake.lock            # pinned inputs — commit this
├── bootstrap.sh          # post-install driver: verify hardware, switch to our flake
├── hardware/             # hand-written, committed, deterministic — describes the
│   ├── vm.nix            #   layout the ISO install must produce; the script
│   └── framework.nix     #   verifies reality matches before switching
└── modules/              # every file here is a top-level module
    ├── nixos.nix             # machinery: options nixos.modules / nixos.configurations
    ├── home-manager.nix      # machinery: options homeManager.modules + wiring
    ├── users.nix             # noah: account + attaching home bags to him
    ├── ssh.nix               # lab VM access
    ├── networking.nix        # NetworkManager, firewall
    ├── tools.nix             # baseline CLI tools
    ├── hyprland.nix          # ONE feature: NixOS parts + home-manager parts
    ├── audio.nix             # PipeWire
    ├── fonts.nix
    ├── shell/                # bash + starship (real starship.toml nested here)
    ├── terminal/ghostty.nix
    └── computers/            # assembly points: pick bags + machine-specific bits
        ├── vm.nix
        └── framework.nix
```

Bags (merge-point names): `base` = every machine, `workstation` = GUI machines.
A feature file's presence *is* its enabling — no `enable` flags, no `mkEnableOption`.

## Machines

| Name | What |
|---|---|
| `vm` | disposable lab VM — Hyprland, ssh (`noah` / `changeme` on first boot) |
| `framework` | Framework 13 (Ryzen AI 9 HX 370 / Radeon 890M) |

## Install (ISO install first, script second)

1. Install NixOS from the installer ISO (graphical installer or the console
   ceremony — either is fine). Plain layout: one ESP + one root, no LUKS, so
   the install matches the committed `hardware/*.nix` files.
2. Boot into the installed system, then:

```bash
nix-shell -p git
git clone https://github.com/noahhhx/nixos && cd nixos
sudo ./bootstrap.sh <vm|framework>
```

3. Reboot.

## The loop

```
host: edit modules/...  →  nix flake check && git push
vm:   git pull && sudo nixos-rebuild switch --flake .#vm
```

Debug: `nix repl`, `:lf .`, walk `nixosConfigurations.vm.config...` with TAB.
First boot is a bare TTY: log in, then `uwsm start hyprland-uwsm.desktop`.
