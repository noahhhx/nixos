# modules/shell/default.nix — the shell feature (base: every machine gets it).
# starship is ported from the real ~/.config/starship.toml — the raw file nests
# here and import-tree ignores non-Nix files (Phase 6, "paths are free").
{ ... }: {
  homeManager.modules.base = {
    programs.bash.enable = true;
    programs.starship = {
      enable = true;
      settings = builtins.fromTOML (builtins.readFile ./starship.toml);
    };
  };
}
