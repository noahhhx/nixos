{ ... }:
{
  # nixpkgs ships zed-editor's binary as `zeditor` (renamed to avoid clashing
  # with the zfs `zed` daemon, which is what command-not-found suggests),
  # so expose the conventional `zed` name to interactive shells.
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
