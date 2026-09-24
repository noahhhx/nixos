{ ... }:
{
  flake.modules.nixos.hyprland =
    { lib, pkgs, ... }:
    {
      programs.hyprland.enable = true;
      # nixpkgs defaults withUWSM to false; without uwsm's systemd user units
      # the greetd session fails with "Unit wayland-session-bindpid@... not
      # found" and the login bounces back to the greeter.
      programs.hyprland.withUWSM = true;

      # start-hyprland is Hyprland 0.55's watchdog launcher (the bare binary
      # warns "started without start-hyprland, highly not recommended"); bare
      # name resolved via PATH per the nixpkgs uwsm module, avoiding version
      # mismatch.
      services.greetd = {
        enable = true;
        settings.default_session = {
          command = "${lib.getExe pkgs.greetd.tuigreet} --time --cmd '${lib.getExe pkgs.uwsm} start -- start-hyprland'";
          user = "greeter";
        };
      };

      # gtk portal as fallback for interfaces hyprland's portal does not implement.
      xdg.portal = {
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
        config.common.default = [
          "hyprland"
          "gtk"
        ];
      };

      environment.systemPackages = [ pkgs.brightnessctl ];
      services.udev.packages = [ pkgs.brightnessctl ];
    };

  flake.modules.homeManager.hyprland = {
    xdg.configFile = {
      "hypr/hyprland.lua".source = ./hypr/hyprland.lua;
      "hypr/envs.lua".source = ./hypr/envs.lua;
      "hypr/monitors.lua".source = ./hypr/monitors.lua;
      "hypr/input.lua".source = ./hypr/input.lua;
      "hypr/looknfeel.lua".source = ./hypr/looknfeel.lua;
      "hypr/bindings.lua".source = ./hypr/bindings.lua;
      "hypr/windows.lua".source = ./hypr/windows.lua;
      "hypr/autostart.lua".source = ./hypr/autostart.lua;
    };
  };
}
