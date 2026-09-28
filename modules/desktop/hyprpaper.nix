{ ... }:
{
  flake.modules.homeManager.hyprpaper =
    { ... }:
    {
      services.hyprpaper = {
        enable = true;
        settings = {
          splash = false;
          # hyprpaper >= 0.8 uses `wallpaper { monitor = ...; path = ...; }`
          # blocks; the old one-line `wallpaper = monitor,path` and `preload =`
          # syntax is silently ignored. `"*"` means "every monitor" (per
          # hyprpaper's own source; empty monitor strings are unreliable in
          # hyprlang's special-category handling).
          wallpaper = [
            {
              monitor = "*";
              path = "${./hyprpaper/wallpaper.png}";
            }
          ];
        };
      };
    };
}
