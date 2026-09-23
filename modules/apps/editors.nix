# The "editors" aspect: terminal editors and the default editor.
#
# Zed is the human-facing editor (the "zed" aspect), so EDITOR/VISUAL point
# at its CLI: `zeditor --wait` blocks until the buffer is closed, which is
# what tools like git/sudoedit/pi expect. nano and neovim are the fallbacks
# for places a GUI editor cannot run (bare TTY, ssh without forwarding).
{ ... }:
{
  flake.modules.nixos.editors = {
    environment.sessionVariables = {
      EDITOR = "zeditor --wait";
      VISUAL = "zeditor --wait";
    };
  };

  flake.modules.homeManager.editors =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.nano
        pkgs.neovim
      ];
    };
}
