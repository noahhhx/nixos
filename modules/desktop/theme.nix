{ ... }:
{
  flake.modules.homeManager.theme =
    { pkgs, ... }:
    {
      gtk = {
        enable = true;
        colorScheme = "dark";
        theme = {
          package = pkgs.adw-gtk3;
          name = "adw-gtk3-dark";
        };
      };

      # Qt/KDE apps (Dolphin) need a platform theme and a color scheme outside
      # Plasma; without them they get a half-dark palette with black text.
      qt = {
        enable = true;
        platformTheme.name = "kde";
        style.name = "breeze";
      };
      xdg.configFile."kdeglobals".source =
        "${pkgs.kdePackages.breeze}/share/color-schemes/BreezeDark.colors";
    };
}
