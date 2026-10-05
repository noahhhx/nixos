{ ... }:
{
  flake.modules.nixos.zed = {
    programs.zsh.shellAliases.zed = "zeditor";
  };

  flake.modules.homeManager.zed =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.zed-editor
        # Zed's Nix extension expects its language server on PATH.
        pkgs.nil
      ];
    };
}
