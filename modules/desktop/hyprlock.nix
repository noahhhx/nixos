# home-manager cannot install the PAM entry; without it hyprlock cannot
# authenticate.
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
