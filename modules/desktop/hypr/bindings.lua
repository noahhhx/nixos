-- Keybindings. mainMod is SUPER ("Windows" key).

local terminal    = "kitty"
local fileManager = "dolphin"
local menu        = "walker"

local mainMod = "SUPER"

-- Applications and window management.
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle only
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
-- Lock the session: logind lock signal -> hypridle's lock_cmd -> hyprlock
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("loginctl lock-session"))

-- Laptop media keys (no modifier needed): volume via wpctl (the
-- WirePlumber CLI, on PATH through the pipewire "audio" aspect),
-- brightness via brightnessctl (NixOS side of the "hyprland" aspect).
-- `locked` keeps them working under hyprlock; `repeating` auto-repeats
-- when held.
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +5%"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })

-- Screenshots (hyprshot, the "hyprshot" aspect): select a region with
-- the mouse (SUPER+SHIFT+S for the Windows snipping-key muscle memory,
-- plus the dedicated Print key where the keyboard has one); SHIFT+Print
-- shoots the focused output, CTRL+Print all outputs.
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m output"))
hl.bind("CTRL + Print", hl.dsp.exec_cmd("hyprshot -m full"))

-- Move focus with mainMod + arrow keys.
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9];
-- move the active window to a workspace with mainMod + SHIFT + [0-9].
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scroll through existing workspaces with mainMod + scroll.
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging.
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
