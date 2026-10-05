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
          fail_timeout = 700;
        };

        background = [
          {
            path = "screenshot";
            blur_passes = 3;
            blur_size = 8;
            brightness = 0.5;
            contrast = 0.8;
          }
        ];

        label = [
          {
            monitor = "";
            text = "cmd[update:60000]date +'%H:%M'";
            position = "0, 210";
            halign = "center";
            valign = "center";
            font_family = "JetBrainsMono Nerd Font";
            font_size = 120;
            color = "rgba(f5e0dcff)";
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
            color = "rgba(a6adc8ff)";
          }
          {
            monitor = "";
            text = "cmd[update:1800000]h=$(date +%H); if [ \"$h\" -lt 05 ]; then g='Good night'; elif [ \"$h\" -lt 12 ]; then g='Good morning'; elif [ \"$h\" -lt 18 ]; then g='Good afternoon'; else g='Good evening'; fi; printf '%s, %s' \"$g\" \"$USER\"";
            position = "0, 45";
            halign = "center";
            valign = "center";
            font_family = "JetBrainsMono Nerd Font";
            font_size = 16;
            color = "rgba(585b70ff)";
          }
          {
            monitor = "";
            text = "󰧶 $USER";
            position = "0, -200";
            halign = "center";
            valign = "center";
            font_family = "JetBrainsMono Nerd Font";
            font_size = 16;
            color = "rgba(585b70ff)";
          }
        ];

        input-field = [
          {
            monitor = "";
            size = "300, 56";
            position = "0, -125";
            halign = "center";
            valign = "center";
            rounding = 0;
            dots_rounding = 0;
            inner_color = "rgba(0f0f0fd9)";
            outer_color = "rgba(ffffff55)";
            outline_thickness = 1;
            check_color = "rgba(cba6f7ff)";
            fail_color = "rgba(f38ba8ff)";
            capslock_color = "rgba(f9e2afcc)";
            bothlock_color = "rgba(f38ba8cc)";
            font_color = "rgba(cdd6f4ff)";
            font_family = "JetBrainsMono Nerd Font";
            dots_center = true;
            dots_size = 0.25;
            dots_spacing = 0.3;
            fade_on_empty = false;
            placeholder_text = "<span foreground=\"##585b70\">Password...</span>";
            fail_text = "<span foreground=\"##f38ba8\">󰅙  Incorrect</span>";
          }
        ];
      };
    };
  };
}
