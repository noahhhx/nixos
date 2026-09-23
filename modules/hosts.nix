# Hosts: the registry that turns aspects into complete NixOS configurations.
#
# The top-level `hosts` option is the single registry of host modules; any
# other module can read it (e.g. verification.nix builds a VM test for every
# entry) or add entries (modules/hosts/<name>.nix, one file per machine).
# Values are `deferredModule`s, so multiple files can contribute to the same
# host.
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
    flake.nixosConfigurations = lib.mapAttrs (
      name: host: inputs.nixpkgs.lib.nixosSystem { modules = [ host ]; }
    ) config.hosts;
  };
}
