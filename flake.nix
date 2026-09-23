{
  description = "NixOS configuration following the Dendritic pattern";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    import-tree.url = "github:denful/import-tree";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        # Auto-import every .nix file under ./modules as a top-level
        # (flake-parts) module. Paths containing /_ are ignored.
        (inputs.import-tree ./modules)

        # Provides the `flake.modules.<class>.<aspect>` option that feature
        # modules use to contribute lower-level (NixOS, home-manager, ...)
        # configuration.
        inputs.flake-parts.flakeModules.modules
      ];
    };
}
