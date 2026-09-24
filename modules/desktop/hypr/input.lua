hl.config({
    input = {
        kb_options = "compose:caps",

        repeat_rate        = 40,
        repeat_delay       = 600,
        numlock_by_default = true,

        touchpad = {
            natural_scroll       = true,
            scroll_factor        = 0.4,
            clickfinger_behavior = true,
        },
    },
})

-- Logitech mice: no acceleration.
for _, name in ipairs({
    "logitech-usb-receiver",
    "logitech-pro-x-wireless-1",
    "logitech-pro-x-wireless-2",
    "logitech-pro-x-1",
}) do
    hl.device({ name = name, sensitivity = 0, accel_profile = "flat" })
end

hl.window_rule({
    match           = { class = "kitty" },
    scroll_touchpad = 1.5,
})
