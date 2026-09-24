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

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # nixpkgs only ships wlrctl, a different tool.
    wlctl = {
      url = "github:aashish-thapa/wlctl";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # walker 2.x needs the elephant provider daemon; nixpkgs' elephant ships
    # without providers.
    elephant = {
      url = "github:abenz1267/elephant";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    walker = {
      url = "github:abenz1267/walker";
      inputs.elephant.follows = "elephant";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # zsh and oh-my-posh are wrapped via this library so their rc files and
    # prompt config ship inside the derivation.
    wrappers = {
      url = "github:nix-community/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        (inputs.import-tree ./modules)

        inputs.flake-parts.flakeModules.modules
      ];
    };
}
