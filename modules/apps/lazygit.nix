# The "lazygit" aspect: the terminal UI for git.
#
# kitty renders JetBrainsMono Nerd Font, so lazygit's file icons are on.
{ ... }:
{
  flake.modules.homeManager.lazygit = {
    programs.lazygit = {
      enable = true;
      settings.gui.nerdFontsVersion = "3";
    };
  };
}
