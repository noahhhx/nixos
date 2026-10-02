{ config, ... }:
let
  inherit (config.flake.modules) nixos homeManager;
in
{
  flake.modules.nixos.desktop = {
    imports = with nixos; [
      base
      dolphin
      editors
      fonts
      home-manager
      hyprland
      hyprlock
      keyring
      regreet
      user
      devenv
      intellij
      zsh
      zed
    ];
  };

  flake.modules.homeManager.desktop = {
    imports = with homeManager; [
      home
      hyprland
      hypridle
      hyprlock
      hyprpaper
      hyprpolkitagent
      hyprshot
      mako
      swayosd
      walker
      waybar
      kitty
      theme
      cursor
      git
      zed
      intellij
      pi
      devenv
      librewolf
      dolphin
      editors
      fastfetch
      btop
      moonlight
      bluetui
      wlctl
      wiremix
      ssh
      github-desktop
      lazydocker
      lazygit
      herdr
    ];
  };
}
