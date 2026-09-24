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
