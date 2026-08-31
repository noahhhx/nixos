# modules/terminal/ghostty.nix — the terminal feature (workstation bag)
{ ... }: {
  homeManager.modules.workstation = {
    programs.ghostty = {
      enable = true;
      settings = {
        font-size = 11;
        # theme = "catppuccin-mocha";
        window-padding-x = 8;
        window-padding-y = 8;
      };
    };
  };
}
