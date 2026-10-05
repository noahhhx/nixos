{ ... }:
{
  flake.modules.homeManager.cursor =
    { pkgs, ... }:
    {
      home.pointerCursor = {
        name = "DMZ-Black";
        package = pkgs.vanilla-dmz;
        size = 24;
        gtk.enable = true;
        hyprcursor.enable = true;
      };
    };
}
