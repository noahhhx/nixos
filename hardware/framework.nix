# hardware/framework.nix — hand-written and committed, exactly like the VM's:
# it describes the layout a standard ISO install is expected to produce
# (ESP + root on /dev/nvme0n1), and bootstrap.sh refuses to switch if the disk
# it's booted from doesn't match. The copy-from-/etc/nixos branch in the script
# stays as a fallback for machines you haven't written hardware for yet.
{
  fileSystems."/"     = { device = "/dev/nvme0n1p2"; fsType = "ext4"; };
  fileSystems."/boot" = { device = "/dev/nvme0n1p1"; fsType = "vfat"; };
  boot = {
    initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "sd_mod" ];
    loader.systemd-boot.enable = true;
  };
  swapDevices = [ ];
}
