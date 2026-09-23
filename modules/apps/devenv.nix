# The "devenv" aspect: per-project development environments via devenv
# (https://devenv.sh). Languages and dependencies are declared in each
# project's own devenv.nix (composed by that project's flake with its own
# devenv input) — this machine only provides the common machinery:
#   - the devenv CLI (from the pinned nixpkgs channel)
#   - direnv + nix-direnv, so entering a project directory activates its
#     environment automatically (direnv reads the .envrc devenv generates)
#   - the devenv binary cache, so project shells reuse devenv's prebuilt
#     packages instead of rebuilding large dependency trees from source
{
  flake.modules.nixos.devenv = {
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
