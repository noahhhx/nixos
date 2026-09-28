{ ... }:
{
  flake.modules.nixos.hyprland =
    { pkgs, ... }:
    {
      programs.hyprland.enable = true;
      # nixpkgs defaults withUWSM to false; without uwsm's systemd user units
      # the greetd session fails with "Unit wayland-session-bindpid@... not
      # found" and the login bounces back to the greeter. With it, the package
      # also provides the "Hyprland (uwsm-managed)" wayland session entry the
      # regreet greeter launches (see modules/desktop/regreet.nix).
      programs.hyprland.withUWSM = true;

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
