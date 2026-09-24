# `idea` is unfree (bundles JetBrains' proprietary runtime), so every package
# set that evaluates it needs the allowance:
#  - perSystem: flake-parts injects pkgs at mkOptionDefault priority, so an
#    explicit import wins;
#  - nixos: the NixOS test framework injects its own pkgs (nixpkgs.pkgs) into
#    VM-test nodes and forbids nixpkgs.config there, hence the mkIf guard.
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
