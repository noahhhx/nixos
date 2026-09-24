# The "kitty" aspect: terminal emulator, with its config as a plain file
# under kitty/ installed verbatim into ~/.config/kitty/ (mirroring the
# "hyprland" aspect's approach for ~/.config/hypr/).
#
# The home-manager kitty module is deliberately not used: it always
# generates its own kitty.conf, which would collide with ours. What it
# does beyond writing the file is replicated here — package install and
# the config-reload signal to running instances. (Shell integration needs
# no wiring: kitty enables it automatically for bash/zsh via its launch
# environment, without rc-file edits.)
{ ... }:
{
  flake.modules.homeManager.kitty =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.kitty ];

      xdg.configFile."kitty/kitty.conf" = {
        source = ./kitty/kitty.conf;
        # Ask running kitty instances to pick up the new config (same signal
        # the home-manager module sends).
        onChange = ''
          ${pkgs.procps}/bin/pkill -USR1 -u $USER kitty || true
        '';
      };
    };
}
