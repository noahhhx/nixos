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
            splash = false;
            preload = [ wallpaper ];
            # Empty monitor name (before the comma) means "every monitor".
            wallpaper = [ ",${wallpaper}" ];
          };
      };
    };
}
