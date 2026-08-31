# hardware/vm.nix — hand-written ON PURPOSE: it describes the layout a standard
# ISO install produces on this VM, and bootstrap.sh (run AFTER that install)
# refuses to switch unless the disk it's actually booted from matches this
# file. The Framework's file works the same way.
# It MUST be committed and NOT gitignored: an ignored hardware file is how a hollow
# generated one silently takes its place (Scars, Phase 3).
{
  # device names follow the disk BUS: virtio -> /dev/vda (vm-curator's default —
  # see ~/vm-space/<vm>/launch.sh's -drive line), SATA/AHCI -> /dev/sda.
  # The ISO install's layout and this file must agree on the names.
  fileSystems."/"     = { device = "/dev/vda2"; fsType = "ext4"; };
  fileSystems."/boot" = { device = "/dev/vda1"; fsType = "vfat"; };
  boot = {
    initrd.availableKernelModules = [ "ahci" "sd_mod" "virtio_pci" "virtio_blk" ];
    loader.systemd-boot.enable = true;   # UEFI only — the VM must boot OVMF (Phase 3)
  };
  swapDevices = [ ];   # mind the spelling: `swap.devices` is not an option
}
