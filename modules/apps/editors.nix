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
