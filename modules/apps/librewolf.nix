{ ... }:
let
  font = "JetBrainsMono Nerd Font";
  prefs = {
    "ui.systemUsesDarkTheme" = true;
    "browser.theme.content-theme" = 0;

    # 0 ignores the fonts pages ask for, so every site renders in `font`.
    "browser.display.use_document_fonts" = 0;
    "font.name.serif.x-western" = font;
    "font.name.sans-serif.x-western" = font;
    "font.name.monospace.x-western" = font;
    "font.name.serif.x-unicode" = font;
    "font.name.sans-serif.x-unicode" = font;
    "font.name.monospace.x-unicode" = font;
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
