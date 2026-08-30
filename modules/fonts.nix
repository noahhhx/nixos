# modules/fonts.nix — the fonts feature: defaults plus a nerd font for the
# terminal, and emoji coverage.
{ ... }: {
  nixos.modules.workstation = { pkgs, ... }: {
    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        noto-fonts
        noto-fonts-emoji
      ];
    };
  };
}
