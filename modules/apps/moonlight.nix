{ ... }:
{
  flake.modules.homeManager.moonlight =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.moonlight-qt ];
    };
}
