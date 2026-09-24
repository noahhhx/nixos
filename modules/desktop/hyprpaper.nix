{ ... }:
{
  flake.modules.homeManager.hyprpaper =
    { ... }:
    {
      services.hyprpaper = {
        enable = true;
        settings =
          let
            wallpaper = "${./hyprpaper/wallpaper.png}";
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
