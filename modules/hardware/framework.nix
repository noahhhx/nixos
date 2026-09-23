# The "framework" aspect: hardware support for the Framework Laptop 13
# (AMD Ryzen AI 300 series board — Ryzen AI 9 HX 370, Radeon 890M, MediaTek
# MT7925 WiFi 7/BT, Goodix fingerprint reader). Everything here is
# hardware enablement and works under the VM checks too; disk/boot layout
# is host-specific and lives in hosts.nix.
#
# Kernel notes: amd-pstate-epp is active by default on this platform, and the
# MT7925 is supported by the in-tree mt7925e driver (kernel >= 6.14) with
# firmware from linux-firmware — nothing out-of-tree is needed.
{ lib, ... }:
{
  flake.modules.nixos.framework = {
    # Graphics: Radeon 890M — mesa via hardware.graphics; amdgpu in the
    # initrd gives a native-resolution console from the first frame (the
    # built-in panel is 2256x1504).
    hardware.graphics.enable = true;
    hardware.amdgpu.initrd.enable = true;

    # Networking: WiFi + Bluetooth live on the same MT7925 chip.
    networking.networkmanager.enable = true;
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true; # Reachable for pairing right after boot
    };

    # Fingerprint reader (Goodix 27c6:609c, supported by libfprint's
    # goodixmoc driver). Enroll after install with `fprintd-enroll`.
    services.fprintd.enable = true;

    # System (BIOS/EC) and expansion-card firmware updates via LVFS.
    services.fwupd.enable = true;

    # zram swap: full-RAM zstd zram, zswap off — matches what this machine
    # already runs (62G zram on 64G RAM, only allocated as used).
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 100;
    };
  };
}
