{ ... }:
{
  flake.modules.homeManager.kitty =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.kitty ];

      xdg.configFile."kitty/kitty.conf" = {
        source = ./kitty/kitty.conf;
        onChange = ''
          ${pkgs.procps}/bin/pkill -USR1 -u $USER kitty || true
        '';
      };
    };
}
