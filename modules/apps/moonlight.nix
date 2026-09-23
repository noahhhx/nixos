# The "moonlight" aspect: Moonlight game-streaming client (pairs with a
# Sunshine host on another machine).
{ ... }:
{
  flake.modules.homeManager.moonlight =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.moonlight-qt ];
    };
}
