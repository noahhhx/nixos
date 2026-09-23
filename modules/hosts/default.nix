# The "default" host: a placeholder generic x86_64 machine with the full
# desktop stack. It backs the VM checks and serves as the template for real
# hosts; there is no physical machine behind it.
{ config, lib, ... }:
let
  inherit (config.flake.modules) nixos homeManager;
in
{
  hosts.default = {
    imports = [ nixos.desktop ];

    home-manager.users.noah = {
      home.stateVersion = "25.05";
      imports = [ homeManager.desktop ];
    };

    networking.hostName = "default";
    nixpkgs.hostPlatform = "x86_64-linux";
    system.stateVersion = "25.05";

    # Placeholder boot setup so the closure builds and boots in a VM.
    # Replace per real host (mkDefault lets the VM/test framework override).
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
