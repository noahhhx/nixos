# The "waybar" aspect: status bar, with waybar's default configuration.
# Runs as a systemd user service started with the graphical session (uwsm).
{ ... }:
{
  flake.modules.homeManager.waybar = {
    programs.waybar = {
      enable = true;
      systemd.enable = true;
    };
  };
}
