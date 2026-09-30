# The "wiremix" aspect: a PipeWire mixer TUI for picking the default
# output/input device and setting per-device and per-stream volumes.
#
# Like bluetui and wlctl it runs inside kitty, launched from its waybar
# module (the pulseaudio icon, modules/desktop/waybar/config.jsonc) as a
# floating popup (the waybar-tui-float rule, modules/desktop/hypr/windows.lua). Its
# styling lives in ./wiremix/wiremix.toml, which is merged over wiremix's
# built-in defaults.
{ ... }:
{
  flake.modules.homeManager.wiremix =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.wiremix ];

      xdg.configFile."wiremix/wiremix.toml".source = ./wiremix/wiremix.toml;
    };
}
