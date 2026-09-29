{ ... }:
{
  flake.modules.homeManager.hypridle = {
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          # Runs on logind's PrepareForSleep, so this locks on *any* suspend
          # (manual `systemctl suspend` included), not just hypridle's own
          # idle-triggered one. pidof guard avoids stacking a second instance.
          before_sleep_cmd = "pidof hyprlock || hyprlock; hyprctl dispatch dpms off";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };

        listener = [
          {
            timeout = 300;
            on-timeout = "pidof hyprlock || hyprlock";
          }
          {
            timeout = 330;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          {
            timeout = 1800;
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };
  };
}
