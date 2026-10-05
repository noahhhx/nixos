## Environment

- This machine runs NixOS on a Framework Laptop 13 with an AMD Ryzen AI 9 HX 370 (x86_64, 4 Zen 5 and 8 Zen 5c cores, 24 threads) and a Radeon 890M iGPU.
- Nix manages all software. Never install packages into the system with curl, pip, or npm. Make system changes in the flake repo at `~/nixos`.
- `~/nixos` versions the OS configuration, the home-manager configuration, the `pi` CLI, and these machine-specific instructions and skills. The instructions and skills live in `modules/apps/pi/` in that repo.
- The portable agent setup comes from the `pi-shop` repository, which `~/nixos` uses as a flake input. It provides the global AGENTS.md base, skills, and extensions such as pi-fff.
- The shell is zsh with carapace completions. The editors are Zed and IntelliJ.
- Secrets are sops-encrypted. Never write plaintext credentials into the repo or into a command history.

## Change the system

To change the system configuration, or to rebuild or switch, use the `nixos-rebuild` skill. It covers the repo layout, the verification tiers, and the switch commands. Read `~/nixos/AGENTS.md` before you edit anything in that repo.
