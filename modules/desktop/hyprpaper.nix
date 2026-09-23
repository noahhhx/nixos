# The "hyprpaper" aspect: the wallpaper daemon of the Hypr ecosystem.
# Runs as a systemd user service started with the graphical session (uwsm)
# and paints a wallpaper on every monitor — Hyprland's bundled one until a
# real choice is made (swap the `wallpaper` let-binding).
{ ... }:
{
  flake.modules.homeManager.hyprpaper =
    { pkgs, ... }:
    {
      services.hyprpaper = {
        enable = true;
        settings =
          let
            wallpaper = "${pkgs.hyprland}/share/hypr/wall2.png";
          in
          {
            splash = false; # no version text on the wallpaper
            preload = [ wallpaper ];
            # Empty monitor name (before the comma) means "every monitor".
            wallpaper = [ ",${wallpaper}" ];
          };
      };
    };
}
