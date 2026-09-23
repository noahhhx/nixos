# The "hyprpolkitagent" aspect: the Hypr ecosystem's polkit authentication
# agent. Without a polkit agent, GUI apps that request privilege (fwupd
# frontends, partition managers, some installers) fail silently — this
# gives them a password prompt inside the Wayland session. Runs as a
# systemd user service started with the graphical session (uwsm), like
# waybar/walker.
{ ... }:
{
  flake.modules.homeManager.hyprpolkitagent = {
    services.hyprpolkitagent.enable = true;
  };
}
