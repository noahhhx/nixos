# The "hyprshot" aspect: screenshots for Hyprland — select a region, an
# output or all outputs with the mouse; each shot is copied to the
# clipboard and saved to ~/Pictures, with a toast via the "mako" aspect.
# Keybindings live in the "hyprland" aspect.
#
# The nixpkgs package wraps all of its helpers (grim, slurp, hyprpicker,
# wl-clipboard, libnotify), so nothing else needs installing here.
# https://github.com/Gustash/hyprshot
{ ... }:
{
  flake.modules.homeManager.hyprshot =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.hyprshot ];
    };
}
