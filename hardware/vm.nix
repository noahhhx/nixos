# hardware/vm.nix — hand-written ON PURPOSE: the VM's disk layout is ours to choose,
# and bootstrap.sh partitions to match. The Framework's file works the same way —
# deterministic because the script owns partitioning there too.
# It MUST be committed and NOT gitignored: an ignored hardware file is how a hollow
# generated one silently takes its place (Scars, Phase 3).
{
  # device names follow the disk BUS: virtio -> /dev/vda (vm-curator's default —
  # see ~/vm-space/<vm>/launch.sh's -drive line), SATA/AHCI -> /dev/sda.
  # Script and file must agree on the names.
  fileSystems."/"     = { device = "/dev/vda2"; fsType = "ext4"; };
  fileSystems."/boot" = { device = "/dev/vda1"; fsType = "vfat"; };
  boot = {
    initrd.availableKernelModules = [ "ahci" "sd_mod" "virtio_pci" "virtio_blk" ];
    loader.systemd-boot.enable = true;   # UEFI only — the VM must boot OVMF (Phase 3)
  };
  swapDevices = [ ];   # mind the spelling: `swap.devices` is not an option
}
