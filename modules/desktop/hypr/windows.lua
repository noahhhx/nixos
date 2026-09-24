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
