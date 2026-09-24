-- waybar, hyprpaper and walker are started by their systemd user services
-- from the Nix config instead of exec-once.
hl.on("hyprland.start", function()
    hl.exec_cmd('gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"')
    hl.exec_cmd('gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"')
end)
