{ lib, ... }:
{
  fileSystems."/" = lib.mkDefault {
    device = "/dev/vda";
    fsType = "ext4";
  };
}
