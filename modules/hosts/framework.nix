{ config, lib, ... }:
let
  inherit (config.flake.modules) nixos homeManager;
in
{
  hosts.framework = {
    imports = [
      nixos.desktop
      nixos.audio
      nixos.framework
      nixos.tailscale
      nixos.mullvad
      nixos.docker
      nixos.secrets
    ];

    home-manager.users.noah = {
      home.stateVersion = "26.05";
      imports = [ homeManager.desktop ];
    };

    networking.hostName = "framework";
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
