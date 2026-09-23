# The "git" aspect: version control, with home-manager defaults.
# Set programs.git.userName / userEmail here when you want them managed too.
{ ... }:
{
  flake.modules.homeManager.git = {
    programs.git.enable = true;
  };
}
