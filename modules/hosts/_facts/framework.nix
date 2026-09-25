{ lib, ... }:
{
  boot.loader.grub = {
    enable = lib.mkDefault true;
    device = lib.mkDefault "/dev/vda";
  };
  fileSystems."/" = lib.mkDefault {
    device = "/dev/vda";
    fsType = "ext4";
  };
}
