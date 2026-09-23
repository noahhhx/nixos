# The "hyprlock" aspect: the GPU-accelerated lock screen of the Hypr
# ecosystem, invoked by the "hypridle" aspect (and SUPER+L in the "hyprland"
# aspect). The screen is configured on the home-manager side; the NixOS side
# carries the PAM entry that home-manager cannot install — without it
# hyprlock cannot authenticate the user.
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
        };

        # Blurred snapshot of the current screen as the lock backdrop.
        background = [
          {
            path = "screenshot";
            blur_passes = 3;
            blur_size = 8;
          }
        ];

        input-field = [
          {
            monitor = ""; # all monitors
            size = "200, 50";
            position = "0, -80";
            dots_center = true;
            fade_on_empty = false;
            outline_thickness = 5;
            placeholder_text = "'<span foreground=\"##cad3f5\">Password...</span>'";
          }
        ];

        label = [
          {
            monitor = "";
            text = "Hi, $USER";
            position = "0, 80";
            font_size = 25;
          }
        ];
      };
    };
  };
}
