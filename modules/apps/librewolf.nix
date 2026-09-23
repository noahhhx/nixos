# The "librewolf" aspect: web browser.
{ ... }:
{
  flake.modules.homeManager.librewolf =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.librewolf ];

      # Default web handler: `xdg-open` on links and HTML files goes to
      # LibreWolf (without this, a fresh profile has no default browser,
      # so xdg-open fails or picks something arbitrary).
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
