{
  description = "NixOS configuration following the Dendritic pattern";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    import-tree.url = "github:denful/import-tree";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Application-launcher stack: walker 2.x requires the elephant provider
    # daemon, and nixpkgs ships elephant without providers, so both come from
    # upstream.
    elephant = {
      url = "github:abenz1267/elephant";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    walker = {
      url = "github:abenz1267/walker";
      inputs.elephant.follows = "elephant";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
