# The "hyprland" aspect: the Hyprland Wayland compositor (nixpkgs ships
# 0.55+, i.e. the Lua-config era) started from greetd under uwsm, so that
# systemd user services (waybar, walker, elephant) activate with the
# graphical session.
#
# NixOS side: compositor + a minimal greeter.
# home-manager side: a minimal ~/.config/hypr/hyprland.lua (Hyprland would
# auto-generate one, but we need our own terminal/launcher binds).
{ ... }:
{
  flake.modules.nixos.hyprland =
    { lib, pkgs, ... }:
    {
      programs.hyprland.enable = true; # withUWSM is on by default

      # Minimal greeter: textual login on tty, then Hyprland via uwsm.
      services.greetd = {
        enable = true;
        settings.default_session = {
          command = "${lib.getExe pkgs.greetd.tuigreet} --time --cmd '${lib.getExe pkgs.uwsm} start -- ${lib.getExe pkgs.hyprland}'";
          user = "greeter";
        };
      };

      # File chooser / open-with portals for Wayland + GTK apps.
      xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

  flake.modules.homeManager.hyprland = {
    xdg.configFile."hypr/hyprland.lua".text = ''
      -- Minimal Hyprland config, kept close to the upstream example:
      -- https://wiki.hypr.land/Configuring/Start/

      local terminal    = "kitty"
      local fileManager = "dolphin"
      local menu        = "walker"

      -- No autostart needed: waybar, walker and its elephant backend run as
      -- systemd user services bound to graphical-session.target (uwsm).

      ------------------
      ---- MONITORS ----
      ------------------

      hl.monitor({
          output   = "",
          mode     = "preferred",
          position = "auto",
          scale    = "auto",
      })

      -------------------------------
      ---- ENVIRONMENT VARIABLES ----
      -------------------------------

      hl.env("XCURSOR_SIZE", "24")
      hl.env("HYPRCURSOR_SIZE", "24")

      ---------------------
      ---- KEYBINDINGS ----
      ---------------------

      local mainMod = "SUPER" -- "Windows" key

      hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
      hl.bind(mainMod .. " + C", hl.dsp.window.close())
      hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
      hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
      hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
      hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle only
      hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))

      -- Move focus with mainMod + arrow keys
      hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
      hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
      hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
      hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

      -- Switch workspaces with mainMod + [0-9]
      -- Move active window to a workspace with mainMod + SHIFT + [0-9]
      for i = 1, 10 do
          local key = i % 10 -- 10 maps to key 0
          hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
          hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
      end

      -- Scroll through existing workspaces with mainMod + scroll
      hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
      hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

      -- Move/resize windows with mainMod + LMB/RMB and dragging
      hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
      hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

      --------------------------------
      ---- WINDOWS AND WORKSPACES ----
      --------------------------------

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
    '';
  };
}
