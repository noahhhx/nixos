# The "swayosd" aspect: an on-screen display for volume and brightness.
#
# swayosd-server runs as a systemd user service tied to the graphical
# session (like waybar and hyprpaper). The Hyprland media-key bindings
# (modules/desktop/hypr/bindings.lua) call swayosd-client, which talks to
# the server over D-Bus, changes the default sink's volume (through
# PipeWire/Pulse), and pops up a progress-bar OSD. The brightness keys call
# swayosd-brightness instead, which sets the backlight with brightnessctl
# itself and only asks the server to draw the bar (swayosd/brightness.sh
# says why). Backlight write access comes from brightnessctl's
# udev rules, which the hyprland aspect already installs.
{ ... }:
{
  flake.modules.homeManager.swayosd =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.swayosd
        # The brightness keys' handler; see the comment in the script.
        (pkgs.writeShellApplication {
          name = "swayosd-brightness";
          runtimeInputs = [
            pkgs.brightnessctl
            pkgs.swayosd
          ];
          text = builtins.readFile ./swayosd/brightness.sh;
        })
      ];

      xdg.configFile = {
        # swayosd would otherwise allow raising volume up to its 150%
        # default; cap it at 100% like the old `wpctl set-volume -l 1`
        # bindings did. show_percentage gives the OSD a numeric readout
        # next to the bar, like a TUI status line.
        "swayosd/config.toml".text = ''
          [server]
          max_volume = 100
          show_percentage = true
        '';
        # Flat styling (no rounding, 1px border, #0f0f0f base, Catppuccin
        # Mocha accents, JetBrainsMono) matching hyprlock and kitty.
        "swayosd/style.css".source = ./swayosd/style.css;
      };

      systemd.user.services.swayosd = {
        Unit = {
          Description = "SwayOSD volume/brightness on-screen display";
          Documentation = "https://github.com/ErikReider/SwayOSD";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.swayosd}/bin/swayosd-server";
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
}
