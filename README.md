# NixOS Configuration

Automated NixOS install from a git repo using flakes and home-manager.

## Structure

```
nixos/
├── flake.nix                    # Flake entry point
├── flake.lock
├── hosts/
│   └── fw13/
│       ├── configuration.nix    # System configuration
│       ├── home.nix             # Home-manager user config
│       └── hardware-configuration.nix  # Auto-generated (gitignored)
├── scripts/
│   └── install.sh               # Automated install script
└── .gitignore
```

## Automated Install

Boot from a NixOS minimal ISO, then run:

```bash
sudo bash scripts/install.sh https://github.com/<USER>/<REPO>.git fw13
```

Or manually:

```bash
# 1. Partition and mount
# 2. Clone repo
git clone https://github.com/<USER>/<REPO>.git /mnt/etc/nixos
# 3. Generate hardware config
nixos-generate-config --no-filesystems --show-hardware-config --root /mnt --dir /mnt/etc/nixos/hosts/fw13
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

## Adding a New Host

1. Create `hosts/<hostname>/configuration.nix` and `hosts/<hostname>/home.nix`
2. Add the host to `flake.nix`
3. Install with `nixos-install --flake .#<hostname>`
