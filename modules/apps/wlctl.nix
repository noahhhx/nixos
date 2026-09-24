{ inputs, ... }:
{
  flake.modules.homeManager.wlctl =
    { pkgs, ... }:
    {
      home.packages = [ inputs.wlctl.packages.${pkgs.system}.default ];
    };
}
