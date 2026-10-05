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
    };
}
