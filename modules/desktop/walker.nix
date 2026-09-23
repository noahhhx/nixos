# The "walker" aspect: application launcher, backed by the elephant provider
# daemon (walker 2.x requires elephant; nixpkgs ships the daemon without
# providers, so both come from the upstream flakes — see flake.nix).
# https://github.com/abenz1267/walker
{ inputs, ... }:
{
  flake.modules.homeManager.walker = {
    imports = [ inputs.walker.homeManagerModules.default ];

    programs.walker = {
      enable = true;
      # systemd user service: faster launches, starts with the graphical
      # session; also starts the elephant backend it depends on.
      runAsService = true;
    };
  };
}
