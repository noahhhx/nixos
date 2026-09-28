# The "theme" aspect: system-wide dark mode.
#
# Theme-following toolkits (Electron, Firefox/LibreWolf, libadwaita, KDE)
# query the XDG desktop portal's Settings interface for
# org.freedesktop.appearance color-scheme. On this desktop that interface is
# served by xdg-desktop-portal-gtk (the hyprland portal does not implement
# Settings), which maps it to the gsettings key
# org.gnome.desktop.interface color-scheme. Without it the portal answers
# "no preference" and every app defaults to light.
#
# GTK3 apps and Firefox's widget layer additionally need a dark theme by
# name; GTK4/libadwaita apps follow color-scheme on their own.
{ ... }:
{
  flake.modules.homeManager.theme =
    { pkgs, ... }:
    {
      gtk = {
        enable = true;
        # colorScheme = "dark" publishes the preference end to end:
        # dconf org.gnome.desktop.interface color-scheme = "prefer-dark"
        # (what xdg-desktop-portal-gtk serves over the Settings interface)
        # plus gtk-application-prefer-dark-theme in the GTK3/GTK4 settings.
        colorScheme = "dark";
        # GTK3 apps and Firefox's widget layer still need a dark theme by
        # name; GTK4/libadwaita apps follow color-scheme on their own.
        theme = {
          package = pkgs.adw-gtk3;
          name = "adw-gtk3-dark";
        };
      };
    };
}
