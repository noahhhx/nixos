# NixOS Configuration

Automated NixOS install from a git repo using flakes and home-manager.

## Structure

```
nixos/
├── flake.nix                    # Flake entry point
├── flake.lock
├── hosts/
│   ├── fw13/                    # Real laptop (UEFI)
│   │   ├── configuration.nix
│   │   ├── home.nix
│   │   └── hardware-configuration.nix  # Auto-generated (gitignored)
│   └── vm/                      # Virtual machine (no EFI variables)
│       ├── configuration.nix
│       ├── home.nix
│       └── hardware-configuration.nix  # Auto-generated (gitignored)
├── scripts/
│   └── install.sh               # Automated install script
└── .gitignore
```

## Automated Install

Boot from a NixOS minimal ISO, then run:

```bash
# For the real laptop (fw13)
sudo bash <(curl -fsSL https://github.com/noahhhx/nixos/raw/main/scripts/install.sh) https://github.com/noahhhx/nixos.git fw13
```

### Virtual Machine

For VMs, use the `vm` host which disables EFI variable touching:

```bash
# Automated
sudo bash <(curl -fsSL https://github.com/noahhhx/nixos/raw/main/scripts/install.sh) https://github.com/noahhhx/nixos.git vm

# Manual
nix-shell -p git
git clone https://github.com/noahhhx/nixos.git /mnt/etc/nixos
nixos-generate-config --root /mnt --dir /mnt/etc/nixos/hosts/vm
nixos-install --flake /mnt/etc/nixos#vm --no-root-passwd
```

Or manually for the real laptop:

```bash
# 1. Partition and mount
# 2. Clone repo
nix-shell -p git
git clone https://github.com/noahhhx/nixos.git /mnt/etc/nixos
# 3. Generate hardware config
nixos-generate-config --root /mnt --dir /mnt/etc/nixos/hosts/fw13
# 4. Install
nixos-install --flake /mnt/etc/nixos#fw13 --no-root-passwd
# 5. Reboot
```

## Post-Install

After first boot, sync your config to git:

```bash
cd /etc/nixos
git add -A
git commit -m "Initial install"
git push
```

## Rebuilding

On the installed system:

```bash
sudo nixos-rebuild switch --flake .#fw13
```
or for the VM:
```bash
sudo nixos-rebuild switch --flake .#vm
```

## Adding a New Host

1. Create `hosts/<hostname>/configuration.nix` and `hosts/<hostname>/home.nix`
2. Add the host to `flake.nix`
3. Install with `nixos-install --flake .#<hostname>`
