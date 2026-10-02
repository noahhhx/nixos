# The "herdr" aspect: the agent-aware terminal multiplexer (herdr.dev).
#
# The UI follows the host terminal's ANSI palette (kitty's), and agents
# that finish or need input in a background tab raise a desktop
# notification through mako. herdr's "system" delivery shells out to
# notify-send and silently drops the notification when it isn't on PATH,
# so libnotify ships alongside it.
#
# The config is a read-only store symlink, so onboarding is skipped (it
# would try to write `onboarding = false` back); edit settings here.
{ inputs, ... }:
{
  flake.modules.homeManager.herdr =
    { pkgs, ... }:
    {
      home.packages = [
        inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
        pkgs.libnotify
      ];

      xdg.configFile."herdr/config.toml".source = (pkgs.formats.toml { }).generate "herdr-config.toml" {
        onboarding = false;
        theme.name = "terminal";
        ui.toast.delivery = "system";
      };
    };
}
