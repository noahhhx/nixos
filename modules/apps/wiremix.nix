{ ... }:
{
  flake.modules.homeManager.wiremix =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.wiremix ];

      xdg.configFile."wiremix/wiremix.toml".source = ./wiremix/wiremix.toml;
    };
}
