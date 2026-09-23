# The "intellij" aspect: IntelliJ IDEA IDE — the unified distribution that
# replaced the retired Community/Ultimate split in 2025; the free tier
# covers everything the old Community edition had. The package is marked
# unfree because it bundles JetBrains' proprietary runtime, so this aspect
# owns the unfree allowance in both places a package set exists:
#
#  - perSystem (flake-parts): the flake-level package set (checks, VM
#    tests, formatter) is given an instance that allows exactly `idea`.
#    flake-parts injects pkgs with mkOptionDefault priority, so this
#    explicit definition wins.
#  - nixos: real hosts evaluate nixpkgs through the module system
#    (nixosSystem), so the same allowance is set as nixpkgs.config — but
#    guarded: the NixOS test framework injects its own pkgs instance
#    (nixpkgs.pkgs) into VM-test nodes and then forbids any nixpkgs.config,
#    so the definition is skipped there (the perSystem instance above
#    already allows the package).
{ inputs, lib, ... }:
let
  allowIdea = pkg: lib.getName pkg == "idea";
in
{
  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfreePredicate = allowIdea;
      };
    };

  flake.modules.nixos.intellij =
    { config, options, ... }:
    {
      config = lib.mkIf (!options.nixpkgs.pkgs.isDefined) {
        nixpkgs.config.allowUnfreePredicate = allowIdea;
      };
    };

  flake.modules.homeManager.intellij =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.jetbrains.idea ];
    };
}
