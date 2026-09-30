# The home-manager waybar module writes its own config/style files only when
# `settings`/`style` are set; both stay empty so the files below are the ones
# loaded.
{ ... }:
{
  flake.modules.homeManager.waybar =
    { pkgs, ... }:
    {
      programs.waybar = {
        enable = true;
        systemd.enable = true;
        # Hyprland's Lua config evaluates socket dispatches as Lua, so waybar
        # 0.15.0's legacy `dispatch workspace N` fails and workspace clicks do
        # nothing. The patch sends the `hl.dsp.*` forms upstream master uses;
        # drop it once a waybar release > 0.15.0 lands (it will stop applying).
        package = pkgs.waybar.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [ ./waybar/lua-dispatch.patch ];
        });
      };

      # The clock's click popup (config.jsonc); a floating kitty window placed
      # under the bar by the waybar-calendar rule in ../hypr/windows.lua.
      home.packages = [
        (pkgs.writeShellApplication {
          name = "waybar-calendar";
          text = builtins.readFile ./waybar/calendar.sh;
        })
      ];

      xdg.configFile = {
        "waybar/config.jsonc".source = ./waybar/config.jsonc;
        "waybar/style.css".source = ./waybar/style.css;
      };
    };
}
