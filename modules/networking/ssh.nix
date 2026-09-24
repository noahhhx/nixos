{ ... }:
{
  flake.modules.homeManager.ssh =
    { config, ... }:
    {
      programs.ssh = {
        enable = true;
        settings."*.ts.net".user = config.home.username;
      };
    };
}
