hl.monitor({ output = "eDP-1", mode = "preferred@120", position = "-1728x125", scale = 1.666667 })
hl.monitor({ output = "DP-3", mode = "preferred@120", position = "0x0", scale = 1 })

for i = 1, 7 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "DP-3", default = true })
end
