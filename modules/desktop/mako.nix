# The "mako" aspect: the notification daemon.
#
# Styled like the rest of the desktop (hyprlock, swayosd, kitty): flat (no
# rounding), a thin 1px border, the translucent #0f0f0f dark base,
# Catppuccin Mocha text/accents and JetBrainsMono Nerd Font. Popups sit in
# the top-right corner, 10px from the edges like hyprland's gaps_out, so
# they line up with the tiled windows below waybar.
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

        border-size = 1;
        border-radius = 0;
        background-color = "#0f0f0fd9"; # hyprlock's input field fill
        text-color = "#cdd6f4"; # Catppuccin Mocha text
        border-color = "#ffffff55"; # hyprlock's idle outline
        progress-color = "over #cba6f7"; # kitty's active-tab purple

        max-icon-size = 32;
      };
    };

    # Criteria sections are order-sensitive (later ones win), so they stay
    # in extraConfig rather than an unordered attrset.
    services.mako.extraConfig = ''
      [urgency=low]
      text-color=#a6adc8
      border-color=#ffffff22

      [urgency=critical]
      default-timeout=0
      border-color=#f38ba8
    '';
  };
}
