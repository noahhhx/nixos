{ ... }:
{
  flake.modules.homeManager.swayosd =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.swayosd
        (pkgs.writeShellApplication {
          name = "swayosd-brightness";
          runtimeInputs = [
            pkgs.brightnessctl
            pkgs.swayosd
          ];
          text = builtins.readFile ./swayosd/brightness.sh;
        })
      ];

      xdg.configFile = {
        "swayosd/config.toml".text = ''
          [server]
          max_volume = 100
          show_percentage = true
        '';
        "swayosd/style.css".source = ./swayosd/style.css;
      };

      systemd.user.services.swayosd = {
        Unit = {
          Description = "SwayOSD volume/brightness on-screen display";
          Documentation = "https://github.com/ErikReider/SwayOSD";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.swayosd}/bin/swayosd-server";
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
}
