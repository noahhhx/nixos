# Hosts: composes aspects into complete NixOS configurations.
#
# The top-level `hosts` option is the single registry of host modules; any
# other module can read it (e.g. verification.nix builds a VM test for every
# entry). Values are `deferredModule`s, so multiple files can contribute to
# the same host.
{
  config,
  inputs,
  lib,
  ...
}:
{
  options.hosts = lib.mkOption {
    type = lib.types.attrsOf lib.types.deferredModule;
    default = { };
    description = "Complete NixOS host modules (composed aspects + host-specific settings), keyed by host name.";
  };

  config = {
    hosts.default = {
      imports = with config.flake.modules.nixos; [ base ];

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

    flake.nixosConfigurations = lib.mapAttrs (
      name: host: inputs.nixpkgs.lib.nixosSystem { modules = [ host ]; }
    ) config.hosts;
  };
}
