hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

local activeOpacity, inactiveOpacity = 0.97, 0.9
hl.window_rule({
    match    = { class = ".*" },
    opacity  = activeOpacity .. " " .. inactiveOpacity,
})

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

hl.window_rule({
    name  = "waybar-tui-float",
    match = { class = "^(wiremix|bluetui|wlctl|btop)$" },

    float  = true,
    size   = "900 600",
    center = true,
})

local waybarHeight, gapsOut = 26, 10
local calendarW, calendarH = 240, 200
hl.window_rule({
    name  = "waybar-calendar",
    match = { class = "^waybar-calendar$" },

    float = true,
    size  = calendarW .. " " .. calendarH,
    -- window_w here is kitty's remembered size from its last closed window,
    -- not the size above, so center on the known width instead.
    move  = "monitor_w*0.5-" .. calendarW / 2 .. " " .. waybarHeight + gapsOut,
})
