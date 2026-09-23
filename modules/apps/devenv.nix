# The "devenv" aspect: per-project development environments via devenv
# (https://devenv.sh). Languages and dependencies are declared in each
# project's own devenv.nix (composed by that project's flake with its own
# devenv input) — this machine only provides the common machinery:
#   - the devenv CLI (from the pinned nixpkgs channel)
#   - direnv + nix-direnv, so entering a project directory activates its
#     environment automatically (direnv reads the .envrc devenv generates)
#   - the devenv binary cache, so project shells reuse devenv's prebuilt
#     packages instead of rebuilding large dependency trees from source
#   - nix-ld, so unpatched dynamically-linked binaries (downloaded IDE
#     tarballs, self-updating language servers, vendor toolchains) run
#     without patchelf
#   - a prebuilt nix-index database plus `,` (comma), to run any nixpkgs
#     package ad hoc without installing it
{
  inputs,
  ...
}:
{
  flake.modules.nixos.devenv = {
    imports = [
      # Prebuilt nix-index database, so `nix-locate` and command-not-found
      # suggestions work immediately instead of after a multi-hour index
      # build.
      inputs.nix-index-database.nixosModules.nix-index
    ];

    nix.settings = {
      substituters = [
        "https://devenv.cachix.org"
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];

      # Keep build-time closures alive so direnv-cached dev shells stay
      # valid across garbage collection (recommended by nix-direnv).
      keep-outputs = true;
      keep-derivations = true;
    };

    # Unpatched binaries get the loader they expect from nix-ld.
    programs.nix-ld.enable = true;

    # `, <package>` runs any nixpkgs package on demand (e.g.
    # `, hello`, `, nmap`), backed by the prebuilt index above.
    programs.nix-index-database.comma.enable = true;
  };

  flake.modules.homeManager.devenv =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.devenv ];

      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
    };
}
