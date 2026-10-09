{ ... }:
let
  prefs = {
    "ui.systemUsesDarkTheme" = true;
    "browser.theme.content-theme" = 0;
  };
in
{
  flake.modules.homeManager.librewolf =
    { lib, pkgs, ... }:
    {
      programs.librewolf = {
        enable = true;
        # home-manager's `settings` writes ~/.librewolf/librewolf.overrides.cfg,
        # which this build never reads. extraPrefs lands in mozilla.cfg instead.
        package = pkgs.librewolf.override {
          extraPrefs = lib.concatStrings (
            lib.mapAttrsToList (name: value: ''
              defaultPref("${name}", ${builtins.toJSON value});
            '') prefs
          );
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
