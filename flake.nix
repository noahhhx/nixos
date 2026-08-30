{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
        flake-parts.url = "github:hercules-ci/flake-parts";
        home-manager = {
            # release branch matched to nixpkgs — master tracks unstable and
            # can drift incompatible with a stable nixpkgs
            url = "github:nix-community/home-manager/release-26.05";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        import-tree.url = "github:denful/import-tree";
        nixos-hardware.url = "github:NixOS/nixos-hardware";
    };

    outputs = inputs:
        inputs.flake-parts.lib.mkFlake { inherit inputs; }
            (inputs.import-tree ./modules);
}
