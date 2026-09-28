# The "hyprlock" aspect: the Wayland screen locker.
#
# NixOS side installs the PAM entry (home-manager cannot); without it hyprlock
# cannot authenticate. The home-manager side carries the actual rice, which
# follows the rest of the desktop's look: flat (no rounding, square dots),
# thin 1px borders, the #0f0f0f dark base, Catppuccin Mocha accents and
# JetBrainsMono Nerd Font.
#
# Layout (everything anchored to the monitor's center):
#
#     HH:MM          <- clock, huge, rose
#     Friday, 13 February 2026   <- date
#     Good evening, noah          <- time-of-day greeting
#
#        [ ■ ■ ■ ■ ]            <- input field, purple while checking
#           󰧶 noah               <- user hint
#
# The background is a blurred, dimmed live screenshot of the session.
#
# Gotchas this file deliberately avoids (hyprlock 0.9.5 / hyprlang):
#   - Colors are `rgba(...)` and never `#rrggbb`: home-manager's hyprconf
#     writer does not quote strings, and an unquoted `#` starts a hyprlang
#     comment, silently blanking the option.
#   - `cmd[...]` label text takes everything after `]` as the command; there
#     must be no `;` after the bracket (it would be part of the command).
{ ... }:
{
  flake.modules.nixos.hyprlock = {
    security.pam.services.hyprlock = { };
  };

  flake.modules.homeManager.hyprlock = {
    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          hide_cursor = true;
          ignore_empty_input = true;
          # ms after a failed attempt before the state clears.
          fail_timeout = 700;
        };

        # Dim + blur the live screenshot so text stays readable over
        # whatever was on screen when it locked.
        background = [
          {
            path = "screenshot";
            blur_passes = 3;
            blur_size = 8;
            brightness = 0.5;
            contrast = 0.8;
          }
        ];

        # Clock. cmd labels re-run their command on the given interval,
        # so the time stays live while locked.
        label = [
          {
            monitor = "";
            text = "cmd[update:60000]date +'%H:%M'";
            position = "0, 210";
            halign = "center";
            valign = "center";
            font_family = "JetBrainsMono Nerd Font";
            font_size = 120;
            color = "rgba(f5e0dcff)"; # the rose accent, like the kitty cursor
            # Subtle drop shadow, matching hyprland's (range 2, power 3).
            # hyprlock enables shadows via shadow_passes, not a `shadow` bool.
            shadow_color = "rgba(00000088)";
            shadow_size = 2;
            shadow_passes = 2;
          }
          {
            monitor = "";
            text = "cmd[update:36000000]date +'%A, %d %B %Y'";
            position = "0, 105";
            halign = "center";
            valign = "center";
            font_family = "JetBrainsMono Nerd Font";
            font_size = 21;
            color = "rgba(a6adc8ff)"; # Catppuccin Mocha subtext1
          }
          {
            monitor = "";
            text = "cmd[update:1800000]h=$(date +%H); if [ \"$h\" -lt 05 ]; then g='Good night'; elif [ \"$h\" -lt 12 ]; then g='Good morning'; elif [ \"$h\" -lt 18 ]; then g='Good afternoon'; else g='Good evening'; fi; printf '%s, %s' \"$g\" \"$USER\"";
            position = "0, 45";
            halign = "center";
            valign = "center";
            font_family = "JetBrainsMono Nerd Font";
            font_size = 16;
            color = "rgba(585b70ff)"; # Catppuccin Mocha overlay0
          }
          {
            monitor = "";
            text = "󰧶 $USER";
            position = "0, -200";
            halign = "center";
            valign = "center";
            font_family = "JetBrainsMono Nerd Font";
            font_size = 16;
            color = "rgba(585b70ff)"; # Catppuccin Mocha overlay0
          }
        ];

        input-field = [
          {
            monitor = ""; # all monitors
            size = "300, 56";
            position = "0, -125";
            halign = "center";
            valign = "center";
            rounding = 0; # flat, like everything else on this desktop
            dots_rounding = 0; # square dots, to match
            # Flat dark fill with a thin border, like hyprland's window
            # borders; the border color reacts to auth state:
            #   idle -> faint white, checking -> purple, fail -> red
            inner_color = "rgba(0f0f0fd9)";
            outer_color = "rgba(ffffff55)";
            outline_thickness = 1;
            check_color = "rgba(cba6f7ff)"; # the purple from kitty's active tab
            fail_color = "rgba(f38ba8ff)"; # Catppuccin Mocha red
            # Yellow while caps lock is on.
            capslock_color = "rgba(f9e2afcc)";
            bothlock_color = "rgba(f38ba8cc)";
            font_color = "rgba(cdd6f4ff)"; # Catppuccin Mocha text
            font_family = "JetBrainsMono Nerd Font";
            dots_center = true;
            dots_size = 0.25;
            dots_spacing = 0.3;
            fade_on_empty = false;
            placeholder_text = "'<span foreground=\"##585b70\">Password...</span>'";
            fail_text = "'<span foreground=\"##f38ba8\">󰅙  Incorrect</span>'";
          }
        ];
      };
    };
  };
}
