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

    # WiFi/VPN TUI for NetworkManager; not yet in nixpkgs (nixpkgs only has
    # wlrctl, a different tool), so it comes from the upstream flake.
    # Board-specific hardware enablement (community-maintained): EC access
    # via framework-laptop-kmod, audio profiles, power management, panel
    # self-refresh workaround — see modules/hardware/framework.nix.
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    wlctl = {
      url = "github:aashish-thapa/wlctl";
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

    # Encrypted secrets, decrypted on the host from its own SSH host key
    # (see modules/core/secrets.nix for the bootstrap recipe).
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Prebuilt nix-index database plus `,` (comma) for running any nixpkgs
    # package ad hoc — see modules/apps/devenv.nix.
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
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
