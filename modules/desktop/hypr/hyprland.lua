-- Entry point of the Hyprland Lua config (0.55+ era), kept close to the
-- upstream example: https://wiki.hypr.land/Configuring/Start/
--
-- Settings are split into thematic sibling modules, loaded with require
-- (resolved relative to this file's directory, per the Lua config docs:
-- https://wiki.hypr.land/configuring/core/#using-multiple-configuration-files).

require("envs")
require("monitors")
require("bindings")
require("windows")

-- No autostart module: waybar, walker and its elephant backend run as
-- systemd user services bound to graphical-session.target (uwsm).
