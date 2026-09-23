# The "framework" host: the Framework Laptop 13 (AMD Ryzen AI 300 series).
# The full desktop bundle plus board enablement (modules/hardware/).
#
# NO NIXOS INSTALL HAS HAPPENED ON THIS MACHINE YET, so this host
# deliberately carries no disk layout: filesystems, LUKS, swap and the real
# bootloader are install-specific facts, not board enablement, and are only
# committed once they actually exist (generated from the machine at first
# install — see README, "Installing *this* configuration", step 2). Until
# then this host uses the same mkDefault placeholder disk as the sandbox
# `default` host; the VM/test plumbing overrides it, so the host keeps
# building and passing the VM boot checks without pretending to know the
# real disk. See also AGENTS.md rule 8 (no speculative hardware facts).
{ config, lib, ... }:
let
  inherit (config.flake.modules) nixos homeManager;
in
{
  hosts.framework = {
    imports = [
      nixos.desktop
      nixos.audio
      nixos.framework
      nixos.tailscale
      nixos.mullvad
      nixos.docker
      nixos.secrets
    ];

    home-manager.users.noah = {
      # stateVersion = release at first install on this machine.
      home.stateVersion = "26.05";
      imports = [ homeManager.desktop ];
    };

    networking.hostName = "framework";
    nixpkgs.hostPlatform = "x86_64-linux";
    system.stateVersion = "26.05"; # release at first install on this machine

    # Placeholder boot/disk setup so the closure builds and boots in a VM.
    # Replaced wholesale at first install with the machine's real layout
    # (from the installer-generated /etc/nixos/hardware-configuration.nix,
    # or a disko declaration if the install goes that route).
    boot.loader.grub = {
      enable = lib.mkDefault true;
      device = lib.mkDefault "/dev/vda";
    };
    fileSystems."/" = lib.mkDefault {
      device = "/dev/vda";
      fsType = "ext4";
    };
  };
}
