local terminal = "kitty --single-instance"
local browser  = "librewolf"
local menu     = "walker"

local mainMod = "SUPER"

local function bind(keys, dispatcher, description)
    hl.bind(keys, dispatcher, { description = description })
end

bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu), "Launcher")
bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal), "Terminal")
bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd("uwsm-app -- dolphin"), "File manager")
bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd(browser), "Browser")
bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd(terminal .. " -e btop"), "Activity")
bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd(terminal .. " -e lazydocker"), "Docker")
bind(mainMod .. " + SHIFT + G", hl.dsp.exec_cmd("github-desktop"), "Github Desktop")

bind(mainMod .. " + W", hl.dsp.window.close(), "Close window")

bind(mainMod .. " + J", hl.dsp.layout("togglesplit"), "Toggle window split")
bind(mainMod .. " + P", hl.dsp.window.pseudo(), "Pseudo window")
bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }), "Toggle window floating/tiling")
bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }), "Full screen")
bind(mainMod .. " + CTRL + F", hl.dsp.window.fullscreen_state({ internal = 0, client = 2 }), "Tiled full screen")
bind(mainMod .. " + ALT + F", hl.dsp.window.fullscreen({ mode = "maximized" }), "Full width")

bind(mainMod .. " + L", hl.dsp.exec_cmd("pidof hyprlock || hyprlock"), "Lock session")

hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true, description = "Volume up" })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),        { locked = true, repeating = true, description = "Volume down" })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),        { locked = true, repeating = true, description = "Mute audio" })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),      { locked = true, repeating = true, description = "Mute microphone" })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set +5%"),                             { locked = true, repeating = true, description = "Brightness up" })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"),                             { locked = true, repeating = true, description = "Brightness down" })

bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region"), "Screenshot region")
bind("Print",        hl.dsp.exec_cmd("hyprshot -m region"), "Screenshot region")
bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m output"), "Screenshot output")
bind("CTRL + Print",  hl.dsp.exec_cmd("hyprshot -m full"),    "Screenshot full")

bind(mainMod .. " + LEFT",  hl.dsp.focus({ direction = "left" }),  "Move window focus left")
bind(mainMod .. " + RIGHT", hl.dsp.focus({ direction = "right" }), "Move window focus right")
bind(mainMod .. " + UP",    hl.dsp.focus({ direction = "up" }),    "Move window focus up")
bind(mainMod .. " + DOWN",  hl.dsp.focus({ direction = "down" }),  "Move window focus down")

for i = 1, 9 do
    bind(mainMod .. " + " .. i,         hl.dsp.focus({ workspace = i }),   "Switch to workspace " .. i)
    bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }), "Move window to workspace " .. i)
end

bind(mainMod .. " + S",     hl.dsp.workspace.toggle_special("scratchpad"), "Toggle scratchpad")
bind(mainMod .. " + ALT + S", hl.dsp.window.move({ workspace = "special:scratchpad" }), "Move window to scratchpad")

bind(mainMod .. " + TAB",        hl.dsp.focus({ workspace = "e+1" }),     "Next workspace")
bind(mainMod .. " + SHIFT + TAB", hl.dsp.focus({ workspace = "e-1" }),    "Previous workspace")
bind(mainMod .. " + CTRL + TAB", hl.dsp.focus({ workspace = "previous" }), "Former workspace")

bind(mainMod .. " + SHIFT + LEFT",  hl.dsp.window.swap({ direction = "left" }),  "Swap window to the left")
bind(mainMod .. " + SHIFT + RIGHT", hl.dsp.window.swap({ direction = "right" }), "Swap window to the right")
bind(mainMod .. " + SHIFT + UP",    hl.dsp.window.swap({ direction = "up" }),    "Swap window up")
bind(mainMod .. " + SHIFT + DOWN",  hl.dsp.window.swap({ direction = "down" }),  "Swap window down")

-- Binds sharing a key fire in registration order (old config stacked
-- cyclenext + bringactivetotop on ALT+TAB).
bind("ALT + TAB",         hl.dsp.window.cycle_next(), "Cycle to next window")
bind("ALT + TAB",         hl.dsp.window.bring_to_top(), "Reveal active window on top")
bind("ALT + SHIFT + TAB", hl.dsp.window.cycle_next({ next = false }), "Cycle to prev window")
bind("ALT + SHIFT + TAB", hl.dsp.window.bring_to_top(), "Reveal active window on top")

-- Resize active window (code:20 = minus key, code:21 = equal key)
-- code:20 / code:21 are the minus and equal keys.
bind(mainMod .. " + code:20",         hl.dsp.window.resize({ x = -100, y = 0,   relative = true }), "Expand window left")
bind(mainMod .. " + code:21",         hl.dsp.window.resize({ x = 100,  y = 0,   relative = true }), "Shrink window left")
bind(mainMod .. " + SHIFT + code:20", hl.dsp.window.resize({ x = 0,    y = -100, relative = true }), "Shrink window up")
bind(mainMod .. " + SHIFT + code:21", hl.dsp.window.resize({ x = 0,    y = 100,  relative = true }), "Expand window down")

bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), "Scroll active workspace forward")
bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }), "Scroll active workspace backward")

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true, description = "Move window" })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize window" })

bind(mainMod .. " + G",       hl.dsp.group.toggle(), "Toggle window grouping")
bind(mainMod .. " + ALT + G", hl.dsp.window.move({ out_of_group = true }), "Move active window out of group")

bind(mainMod .. " + ALT + LEFT",  hl.dsp.window.move({ into_group = "left" }),  "Move window to group on left")
bind(mainMod .. " + ALT + RIGHT", hl.dsp.window.move({ into_group = "right" }), "Move window to group on right")
bind(mainMod .. " + ALT + UP",    hl.dsp.window.move({ into_group = "up" }),    "Move window to group on top")
bind(mainMod .. " + ALT + DOWN",  hl.dsp.window.move({ into_group = "down" }),  "Move window to group on bottom")

bind(mainMod .. " + ALT + TAB",        hl.dsp.group.next(), "Next window in group")
bind(mainMod .. " + ALT + SHIFT + TAB", hl.dsp.group.prev(), "Previous window in group")
bind(mainMod .. " + ALT + mouse_down", hl.dsp.group.next(), "Next window in group")
bind(mainMod .. " + ALT + mouse_up",   hl.dsp.group.prev(), "Previous window in group")

for i = 1, 5 do
    bind(mainMod .. " + ALT + " .. i, hl.dsp.group.active({ index = i }), "Switch to group window " .. i)
end
