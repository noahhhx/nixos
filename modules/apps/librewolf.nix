{ ... }:
{
  flake.modules.homeManager.librewolf =
    { pkgs, ... }:
    {
      programs.librewolf = {
        enable = true;
        package = pkgs.librewolf;
        settings = {
          "ui.systemUsesDarkTheme" = true;
          "browser.theme.content-theme" = 0;
        };
      };

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "text/html" = "librewolf.desktop";
          "application/xhtml+xml" = "librewolf.desktop";
          "x-scheme-handler/http" = "librewolf.desktop";
          "x-scheme-handler/https" = "librewolf.desktop";
        };
      };
    };
}
