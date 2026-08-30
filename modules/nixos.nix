{ config, inputs, lib, ... }: {
  options.nixos = {
    modules = lib.mkOption {
      type = lib.types.attrsOf lib.types.deferredModule;
      default = {};
    };
    configurations = lib.mkOption {
      type = lib.types.attrsOf lib.types.deferredModule;
      default = {};
    };
  };

  config.flake.nixosConfigurations =
    lib.mapAttrs
      (_: machine: inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ machine ];
      })
      config.nixos.configurations;

  # canonical bag, defined empty so machines can import it before any feature file
  # fills it — Phase 5 feature files MERGE into it (deferredModule value merging).
  # Without this, `with config.nixos.modules; [ ... workstation ]` dies with
  # "undefined variable" until the first workstation feature exists.
  config.nixos.modules.workstation = {};
}
