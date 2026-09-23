# The "home" aspect: base settings shared by every home-manager configuration
# that imports it (the home-manager counterpart of the nixos "base" aspect).
{ ... }:
{
  flake.modules.homeManager.home =
    { config, ... }:
    {
      # greetd/uwsm sessions are not login shells, so the user's profile PATH
      # and XDG_DATA_DIRS would be missing from the compositor, its systemd
      # user services (waybar, walker, elephant) and anything they spawn.
      # environment.d files are read by the systemd user manager, which is
      # where uwsm-launched sessions get their environment.
      systemd.user.sessionVariables = {
        PATH = "/etc/profiles/per-user/${config.home.username}/bin" + ":/run/current-system/sw/bin";
        XDG_DATA_DIRS =
          "/etc/profiles/per-user/${config.home.username}/share"
          + ":/run/current-system/sw/share:/usr/local/share:/usr/share";
      };
    };
}
