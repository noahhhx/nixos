-- Monitor setup. An empty output name matches every connected output;
-- "preferred"/"auto" let Hyprland pick the mode, position and scale.
-- List current monitors and their modes: hyprctl monitors
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})
