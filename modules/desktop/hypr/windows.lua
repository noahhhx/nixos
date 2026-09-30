hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

-- "0.97 0.9" is focused/unfocused opacity.
hl.window_rule({
    match    = { class = ".*" },
    opacity  = "0.97 0.9",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- The TUIs behind the waybar icons (wiremix: audio, bluetui: bluetooth,
-- wlctl: wifi, btop: cpu) open as centred popups. The waybar clicks launch
-- each with `kitty --class <tool>`, which the single kitty instance honours
-- per window.
hl.window_rule({
    name  = "waybar-tui-float",
    match = { class = "^(wiremix|bluetui|wlctl|btop)$" },

    float  = true,
    size   = "900 600",
    center = true,
})

-- The clock's calendar drops down beneath it: horizontally centred like the
-- clock, and 36px from the top (the 26px bar plus the 10px outer gap), level
-- with the tiled windows. The script centres its grid inside the window.
hl.window_rule({
    name  = "waybar-calendar",
    match = { class = "^waybar-calendar$" },

    float = true,
    size  = "240 200",
    move  = "monitor_w*0.5-window_w*0.5 36",
})
