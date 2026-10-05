# The "mako" aspect: the notification daemon.
#
# Same flat language as the rest of the desktop (hyprlock, swayosd, kitty):
# no rounding, Catppuccin Mocha text/accents and JetBrainsMono Nerd Font.
# But a popup has to read as "not a terminal" at a glance, and kitty
# windows are a #0f0f0f fill inside hyprland's 1px white/grey border — so
# notifications deliberately differ on both: a lifted Mocha base fill
# instead of the near-black, and a 2px accent-coloured border instead of a
# neutral one. The body is laid out as a card (dim app-name header, bold
# accent summary, then the body text) rather than a bare block of text.
# Popups sit in the top-right corner, 10px from the edges like hyprland's
# gaps_out, so they line up with the tiled windows below waybar.
{ ... }:
{
  flake.modules.homeManager.mako = {
    services.mako = {
      enable = true;
      settings = {
        default-timeout = 8000;
        max-history = 100;

        font = "JetBrainsMono Nerd Font 10";
        anchor = "top-right";
        margin = "10";
        padding = "12,16";
        width = 360;
        height = 160;

        border-size = 2;
        border-radius = 0;
        background-color = "#1e1e2ef2"; # Catppuccin Mocha base, lifted off kitty's #0f0f0f
        text-color = "#cdd6f4"; # Catppuccin Mocha text
        border-color = "#cba6f7"; # kitty's active-tab purple
        progress-color = "over #45475a"; # Mocha surface1, kitty's color0

        # Pango markup: app name as a dim header (Mocha overlay1), the
        # summary in the border's accent, then the body.
        format = ''<span size="small" color="#7f849c">%a</span>\n<b><span color="#cba6f7">%s</span></b>\n%b'';

        max-icon-size = 32;
      };
    };

    # Criteria sections are order-sensitive (later ones win), so they stay
    # in extraConfig rather than an unordered attrset. Each urgency recolours
    # the border and summary together so the accent stays consistent.
    services.mako.extraConfig = ''
      [urgency=low]
      text-color=#a6adc8
      border-color=#585b70
      format=<span size="small" color="#7f849c">%a</span>\n<b>%s</b>\n%b

      [urgency=critical]
      default-timeout=0
      border-color=#f38ba8
      format=<span size="small" color="#7f849c">%a</span>\n<b><span color="#f38ba8">%s</span></b>\n%b
    '';
  };
}
