{ ... }:
{
  flake.modules.homeManager.waybar = {
    programs.waybar = {
      enable = true;
      systemd.enable = true;
    };
  };
}
