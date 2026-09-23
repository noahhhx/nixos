# The "kitty" aspect: terminal emulator.
{ ... }:
{
  flake.modules.homeManager.kitty = {
    programs.kitty = {
      enable = true;
      # Provided by the "fonts" aspect (nerd-fonts.jetbrains-mono).
      settings.font_family = "JetBrainsMono Nerd Font";
    };
  };
}
