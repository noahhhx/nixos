# The "cursor" aspect: a real mouse cursor instead of Hyprland's fallback.
#
# Without a cursor theme, Hyprland renders its built-in logo cursor.
# home.pointerCursor links the theme into ~/.icons (on hyprcursor's search
# path), exports XCURSOR_THEME for toolkits, and with hyprcursor.enable also
# exports HYPRCURSOR_THEME for Hyprland itself. DMZ-Black is the classic
# X11 cursor: black fill with a white outline. (The package's "Vanilla-DMZ"
# name is a symlink to DMZ-White, the white Windows-style variant.)
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
