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
      programs.hyprland.enable = true;
      # Explicit (nixpkgs' withUWSM defaults to *false*): enabling it pulls in
      # programs.uwsm, which puts uwsm on PATH and installs its systemd user
      # units (wayland-wm@.service, wayland-session-bindpid@.service, ...).
      # Without them the greetd session command ("uwsm start -- hyprland")
      # fails with "Unit wayland-session-bindpid@... not found" and the login
      # bounces straight back to the greeter.
      programs.hyprland.withUWSM = true;

      # Minimal greeter: textual login on tty, then Hyprland via uwsm.
      # The compositor command is `start-hyprland` (Hyprland 0.55's watchdog
      # launcher, which also sets up the Nix env): launching the bare
      # compositor binary instead makes Hyprland warn "started without
      # start-hyprland, highly not recommended". uwsm 0.26 knows it
      # (quirks_start_hyprland applies the same session quirks as hyprland).
      # Bare name, resolved via PATH to /run/current-system/sw/bin, per the
      # nixpkgs uwsm module's guidance (avoids version mismatch).
      services.greetd = {
        enable = true;
        settings.default_session = {
          command = "${lib.getExe pkgs.greetd.tuigreet} --time --cmd '${lib.getExe pkgs.uwsm} start -- start-hyprland'";
          user = "greeter";
        };
      };

      # Portals. Hyprland's own portal (xdg-desktop-portal-hyprland:
      # screencast, screenshot, global-shortcuts) is already pulled in by
      # programs.hyprland above; xdg-desktop-portal-gtk covers the rest
      # (file chooser, open-with) for Wayland + GTK apps. Make the
      # per-interface order explicit with gtk as fallback for everything
      # hyprland does not implement.
      xdg.portal = {
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
        config.common.default = [
          "hyprland"
          "gtk"
        ];
      };

      # Laptop media keys: brightnessctl, used by the XF86MonBrightness
      # binds below. Its udev rule lets the `video` group (see the "user"
      # aspect) write to the backlight devices.
      environment.systemPackages = [ pkgs.brightnessctl ];
      services.udev.packages = [ pkgs.brightnessctl ];
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
      -- Lock the session: logind lock signal -> hypridle's lock_cmd -> hyprlock
      hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("loginctl lock-session"))

      -- Laptop media keys (no modifier needed): volume via wpctl (the
      -- WirePlumber CLI, on PATH through the pipewire "audio" aspect),
      -- brightness via brightnessctl (NixOS side above). `locked` keeps
      -- them working under hyprlock; `repeating` auto-repeats when held.
      hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
      hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
      hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
      hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
      hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +5%"), { locked = true, repeating = true })
      hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })

      -- Screenshots (hyprshot, the "hyprshot" aspect): select a region
      -- with the mouse (SUPER+SHIFT+S for the Windows snipping-key muscle
      -- memory, plus the dedicated Print key where the keyboard has one);
      -- SHIFT+Print shoots the focused output, CTRL+Print all outputs.
      hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region"))
      hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m region"))
      hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m output"))
      hl.bind("CTRL + Print", hl.dsp.exec_cmd("hyprshot -m full"))

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
