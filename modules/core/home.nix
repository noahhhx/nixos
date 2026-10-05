{ ... }:
{
  flake.modules.homeManager.home =
    { config, ... }:
    {
      systemd.user.sessionVariables = {
        PATH = "/etc/profiles/per-user/${config.home.username}/bin" + ":/run/current-system/sw/bin";
        XDG_DATA_DIRS =
          "/etc/profiles/per-user/${config.home.username}/share"
          + ":/run/current-system/sw/share:/usr/local/share:/usr/share";
      };
    };
}
