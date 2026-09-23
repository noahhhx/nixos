# The "framework" host: the Framework Laptop 13 (AMD Ryzen AI 300 series).
# The full desktop bundle plus hardware enablement (modules/hardware/) and
# this machine's real disk layout.
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
    ];

    home-manager.users.noah = {
      # stateVersion = release at first install on this machine.
      home.stateVersion = "26.05";
      imports = [ homeManager.desktop ];
    };

    networking.hostName = "framework";
    nixpkgs.hostPlatform = "x86_64-linux";
    system.stateVersion = "26.05";

    # Real disk (captured from this machine's current install: GPT with a
    # 2G ESP and a LUKS2 root holding btrfs subvolumes @, @home, @log,
    # @pkg). Plain values are fine: the VM/test plumbing replaces the
    # whole fileSystems/luks sets when building VM checks, so this stays
    # host-specific. After reinstalling from scratch, refresh the UUIDs
    # from the generated /etc/nixos/hardware-configuration.nix.
    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    boot.initrd.luks.devices."root" = {
      device = "/dev/disk/by-uuid/87a30974-33c8-4002-b8a8-2153b01f95e2";
      allowDiscards = true; # SSD TRIM through LUKS
    };
    fileSystems = {
      "/boot" = {
        device = "/dev/disk/by-uuid/E2C8-DE43";
        fsType = "vfat";
      };
      "/" = {
        device = "/dev/mapper/root";
        fsType = "btrfs";
        options = [
          "subvol=@"
          "compress=zstd:3"
          "noatime"
        ];
      };
      "/home" = {
        device = "/dev/mapper/root";
        fsType = "btrfs";
        options = [
          "subvol=@home"
          "compress=zstd:3"
          "noatime"
        ];
      };
      "/var/log" = {
        device = "/dev/mapper/root";
        fsType = "btrfs";
        neededForBoot = true;
        options = [
          "subvol=@log"
          "compress=zstd:3"
          "noatime"
        ];
      };
      # @pkg was /var/cache/pacman/pkg under Arch; reused as /var/cache.
      "/var/cache" = {
        device = "/dev/mapper/root";
        fsType = "btrfs";
        options = [
          "subvol=@pkg"
          "compress=zstd:3"
          "noatime"
        ];
      };
    };

    # Hibernate: carry over the previous install's 62G nocow btrfs swapfile
    # at /swap/swapfile (inside subvol @) — the only hibernation-capable swap
    # on this machine, since zram can't hold an image. Priority 0 keeps zram
    # (100) as the paging swap. No resume=/resume_offset kernel params are
    # needed: the kernel detects the hibernation image on the swapfile at
    # swapon time and resumes from it (exactly how the current install works —
    # the journal shows successful hibernate/resume cycles). Suspend needs
    # nothing; this platform sleeps via s2idle by default. On a fresh
    # reinstall recreate the swapfile before switching:
    #   install -d /swap
    #   touch /swap/swapfile && chattr +C /swap/swapfile
    #   dd if=/dev/zero of=/swap/swapfile bs=1M count=63488
    #   chmod 600 /swap/swapfile
    # (dd rather than fallocate: fallocate extents aren't reliably nocow).
    swapDevices = [
      {
        device = "/swap/swapfile";
        priority = 0;
      }
    ];
  };
}
