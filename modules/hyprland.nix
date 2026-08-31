# modules/hyprland.nix — ONE feature, BOTH classes: the NixOS-level Hyprland
# config and the home-manager-level Hyprland config, because this file IS the
# Hyprland feature (the dendritic signature).
{ ... }: {
  nixos.modules.workstation = {
    programs.hyprland = {
      enable = true;
      withUWSM = true;        # you use uwsm under omarchy today
    };
    # the NixOS hyprland module also wires xdg-desktop-portal for you —
    # verifying that claim in `nix repl` is an exercise below
  };
  homeManager.modules.workstation = {
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
      settings = {
        monitor = [ ",preferred,auto,1" ];
        bind = [
          "SUPER + Q, exec, ghostty"    # the terminal feature provides ghostty
          "SUPER + F, test1, 0"
          "SUPER + M, exit"
        ];
        bindm = [
          "SUPER, mouse:272, movewindow"
          "SUPER, mouse:273, resizewindow"
        ];
      };
    };
  };
}
