# hardware/vm.nix — hand-written ON PURPOSE: the VM's disk layout is ours to choose,
# and bootstrap.sh partitions to match. The Framework's file works the same way —
# deterministic because the script owns partitioning there too.
# It MUST be committed and NOT gitignored: an ignored hardware file is how a hollow
# generated one silently takes its place (Scars, Phase 3).
{
  # device names follow the disk BUS: SATA/AHCI -> /dev/sda (vm-curator's default),
  # virtio -> /dev/vda. Verify once with `lsblk` in the console — reading is allowed,
  # editing is not. Script and file must agree on the names.
  fileSystems."/"     = { device = "/dev/sda2"; fsType = "ext4"; };
  fileSystems."/boot" = { device = "/dev/sda1"; fsType = "vfat"; };
  boot = {
    initrd.availableKernelModules = [ "ahci" "sd_mod" "virtio_pci" "virtio_blk" ];
    loader.systemd-boot.enable = true;   # UEFI only — the VM must boot OVMF (Phase 3)
  };
  swapDevices = [ ];   # mind the spelling: `swap.devices` is not an option
}
