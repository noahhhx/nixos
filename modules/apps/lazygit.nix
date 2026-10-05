{ ... }:
{
  flake.modules.homeManager.lazygit = {
    programs.lazygit = {
      enable = true;
      settings.gui.nerdFontsVersion = "3";
    };
  };
}
