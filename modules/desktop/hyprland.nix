{ ... }:
{
  flake.modules.nixos.hyprland =
    { pkgs, ... }:
    {
      programs.hyprland.enable = true;
      programs.hyprland.withUWSM = true;

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
