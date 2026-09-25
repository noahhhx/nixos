{ lib, ... }:
{
  flake.modules.nixos.boot = {
    boot.loader.systemd-boot.enable = lib.mkDefault true;
    boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;
  };
}
