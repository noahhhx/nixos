{ inputs, ... }:
{
  flake.modules.homeManager.powr =
    { pkgs, ... }:
    {
      home.packages = [ inputs.powr.packages.${pkgs.stdenv.hostPlatform.system}.default ];
    };
}
