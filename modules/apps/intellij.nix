{ lib, ... }:
let
  allowIdea = pkg: lib.getName pkg == "idea";
in
{
  flake.modules.nixos.intellij = {
    nixpkgs.config.allowUnfreePredicate = allowIdea;
  };

  flake.modules.homeManager.intellij =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.jetbrains.idea ];
    };
}
