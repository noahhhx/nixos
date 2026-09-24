# The home-manager kitty module is not used: it always generates its own
# kitty.conf, which would collide with ours; the package and reload signal
# are wired by hand.
{ ... }:
{
  flake.modules.homeManager.kitty =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.kitty ];

      xdg.configFile."kitty/kitty.conf" = {
        source = ./kitty/kitty.conf;
        # Same config-reload signal the home-manager module sends.
        onChange = ''
          ${pkgs.procps}/bin/pkill -USR1 -u $USER kitty || true
        '';
      };
    };
}
