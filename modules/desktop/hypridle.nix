# The "hypridle" aspect: the idle daemon of the Hypr ecosystem. Watches for
# session idleness (and logind sleep/lock signals) and reacts by locking the
# screen with hyprlock, blanking the display, and finally suspending the
# machine. Runs as a systemd user service started with the graphical session
# (uwsm).
{ ... }:
{
  flake.modules.homeManager.hypridle = {
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          # Run for logind lock requests (SUPER+L in the "hyprland" aspect,
          # or logind itself before sleep); guard against double-locks.
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "hyprctl dispatch dpms off";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };

        listener = [
          {
            timeout = 300; # 5 min idle: lock
            on-timeout = "pidof hyprlock || hyprlock";
          }
          {
            timeout = 330; # then blank the display
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          {
            timeout = 1800; # 30 min idle: suspend (hibernate on the metal)
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };
  };
}
