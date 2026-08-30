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
}
