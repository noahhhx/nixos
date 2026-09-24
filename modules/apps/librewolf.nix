{ ... }:
{
  flake.modules.homeManager.librewolf =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.librewolf ];

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
