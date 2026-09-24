{ ... }:
{
  flake.modules.homeManager.home =
    { config, ... }:
    {
      # uwsm sessions are not login shells; environment.d (written by
      # sessionVariables) is where the systemd user manager gets its env.
      systemd.user.sessionVariables = {
        PATH = "/etc/profiles/per-user/${config.home.username}/bin" + ":/run/current-system/sw/bin";
        XDG_DATA_DIRS =
          "/etc/profiles/per-user/${config.home.username}/share"
          + ":/run/current-system/sw/share:/usr/local/share:/usr/share";
      };
    };
}
