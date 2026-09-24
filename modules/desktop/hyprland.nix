# The "hyprland" aspect: the Hyprland Wayland compositor (nixpkgs ships
# 0.55+, i.e. the Lua-config era) started from greetd under uwsm, so that
# systemd user services (waybar, walker, elephant) activate with the
# graphical session.
#
# NixOS side: compositor + a minimal greeter.
# home-manager side: the Hyprland Lua config (0.55+ era), as plain files
# under hypr/ installed verbatim into ~/.config/hypr/ — hyprland.lua is the
# entry point that requires its thematic siblings (monitors, bindings,
# ...), mirroring a hand-managed ~/.config/hypr layout.
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
    xdg.configFile = {
      "hypr/hyprland.lua".source = ./hypr/hyprland.lua;
      "hypr/envs.lua".source = ./hypr/envs.lua;
      "hypr/monitors.lua".source = ./hypr/monitors.lua;
      "hypr/bindings.lua".source = ./hypr/bindings.lua;
      "hypr/windows.lua".source = ./hypr/windows.lua;
    };
  };
}
