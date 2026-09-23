# The "framework" aspect: hardware enablement for the Framework Laptop 13
# (AMD Ryzen AI 300 series board — Ryzen AI 9 HX 370, Radeon 890M, MediaTek
# MT7925 WiFi 7/BT). Everything here is board-level enablement: facts about
# the machine itself, independent of how the disk ends up partitioned, and
# all of it works under the VM checks too. Install-specific disk facts
# (fileSystems, LUKS, swap layout) are NOT hardware enablement — they are
# decided and captured at first install and live in the host entry
# (modules/hosts/), never here.
#
# The board-specific nixos-hardware module (framework-amd-ai-300-series)
# contributes the community-maintained enablement: amd-pstate and amdgpu
# defaults, the `amdgpu.dcdebugmask=0x10` kernel param (panel-self-refresh
# hang workaround), the framework-laptop-kmod kernel module (EC access and
# battery charge limits from sysfs) with the cros_ec modules, the snd_acp*
# blacklist (the BIOS wrongly reports a phantom wired audio device), the
# laptop13 audio-enhancement device name, IIO sensors (display brightness
# detection), fwupd, and udev rules for the Ethernet expansion card.
#
# Kernel notes: amd-pstate-epp is active by default on this platform, and the
# MT7925 is supported by the in-tree mt7925e driver (kernel >= 6.14) with
# firmware from linux-firmware — nothing else out-of-tree is needed.
{
  inputs,
  ...
}:
{
  flake.modules.nixos.framework = {
    imports = [ inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series ];

    # Graphics: Radeon 890M — mesa via hardware.graphics; amdgpu in the
    # initrd gives a native-resolution console from the first frame (the
    # built-in panel is 2256x1504).
    hardware.graphics.enable = true;
    hardware.amdgpu.initrd.enable = true;

    # Power: profile switching between AC and battery (AMD platforms have
    # better battery life with PPD than TLP; nixos-hardware sets the same
    # default — this keeps the intent explicit). Pairs with amd-pstate-epp.
    services.power-profiles-daemon.enable = true;

    # Networking: WiFi + Bluetooth live on the same MT7925 chip. WiFi
    # powersave is off — the MT7925's throughput and latency degrade badly
    # with NetworkManager's default powersave enabled.
    networking.networkmanager = {
      enable = true;
      wifi.powersave = false;
    };
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true; # Reachable for pairing right after boot
    };

    # The fingerprint reader (Goodix 27c6:609c) is deliberately unused —
    # plain passwords only. Overrides nixos-hardware's mkDefault true.
    services.fprintd.enable = false;

    # System (BIOS/EC) and expansion-card firmware updates via LVFS.
    services.fwupd.enable = true;

    # zram swap: full-RAM zstd zram, zswap off — zram pages are only
    # allocated as used, so sizing it to RAM costs nothing at idle, and it
    # works in the VM checks. Any disk-backed swap (e.g. for hibernation,
    # which zram can't hold) is an install-time decision made together with
    # the real disk layout in the host entry.
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 100;
    };
  };
}
