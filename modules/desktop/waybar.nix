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
        # nothing. The patch sends the `hl.dsp.*` forms that upstream master uses.
        # Drop the patch when a waybar release newer than 0.15.0 lands. The
        # patch will stop applying then.
        package = pkgs.waybar.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [ ./waybar/lua-dispatch.patch ];
        });
      };

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
