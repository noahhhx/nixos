# The "cursor" aspect: a real mouse cursor instead of Hyprland's fallback.
#
# Without a cursor theme, Hyprland renders its built-in logo cursor.
# home.pointerCursor links the theme into ~/.icons (on hyprcursor's search
# path), exports XCURSOR_THEME for toolkits, and with hyprcursor.enable also
# exports HYPRCURSOR_THEME for Hyprland itself. Vanilla-DMZ is the classic
# X11 cursor: black fill with a white outline.
{ ... }:
{
  flake.modules.homeManager.cursor =
    { pkgs, ... }:
    {
      home.pointerCursor = {
        name = "Vanilla-DMZ";
        package = pkgs.vanilla-dmz;
        size = 24;
        gtk.enable = true;
        hyprcursor.enable = true;
      };
    };
}
