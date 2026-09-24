{ config, lib, ... }:
let
  inherit (config.flake.modules) nixos homeManager;
in
{
  hosts.default = {
    imports = [ nixos.desktop ];

    home-manager.users.noah = {
      home.stateVersion = "26.05";
      imports = [ homeManager.desktop ];
    };

    networking.hostName = "default";
    nixpkgs.hostPlatform = "x86_64-linux";
    system.stateVersion = "26.05";

    boot.loader.grub = {
      enable = lib.mkDefault true;
      device = lib.mkDefault "/dev/vda";
    };
    fileSystems."/" = lib.mkDefault {
      device = "/dev/vda";
      fsType = "ext4";
    };
  };
}
