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
      user
      devenv
      intellij
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
      walker
      waybar
      kitty
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
      ssh
      github-desktop
      lazydocker
    ];
  };
}
