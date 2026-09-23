# The "desktop" aspect: a bundle that composes the entire graphical stack —
# the core system aspects (modules/core/), the Wayland session (the other
# files in this directory) and the user's applications (modules/apps/).
# Hosts import this single aspect instead of listing every sub-aspect
# themselves (see modules/hosts/).
{ config, ... }:
let
  inherit (config.flake.modules) nixos homeManager;
in
{
  flake.modules.nixos.desktop = {
    imports = with nixos; [
      base
      fonts
      home-manager
      hyprland
      hyprlock
      user
    ];
  };

  # The home-manager counterpart, composed per user by each host.
  # Keep the username in sync with the `home-manager.users.<name>` settings
  # in modules/hosts/ and modules/core/user.nix.
  flake.modules.homeManager.desktop = {
    imports = with homeManager; [
      home
      hyprland
      hypridle
      hyprlock
      hyprpaper
      walker
      waybar
      kitty
      git
      zed
      pi
      librewolf
      dolphin
    ];
  };
}
