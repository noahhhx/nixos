# The home-manager waybar module writes its own config/style files only when
# `settings`/`style` are set; both stay empty so the files below are the ones
# loaded.
{ ... }:
{
  flake.modules.homeManager.waybar = {
    programs.waybar = {
      enable = true;
      systemd.enable = true;
    };

    xdg.configFile = {
      "waybar/config.jsonc".source = ./waybar/config.jsonc;
      "waybar/style.css".source = ./waybar/style.css;
    };
  };
}
