# The "vesktop" aspect: Discord through Vesktop, the Vencord project's own
# desktop client (Vencord built in, plus working Wayland screen sharing).
#
# It runs natively on Wayland via the ELECTRON_OZONE_PLATFORM_HINT set in
# modules/desktop/hypr/envs.lua, and goes dark with the rest of the desktop
# through the portal color-scheme (modules/desktop/theme.nix).
#
# Vencord itself is left to Vesktop, which downloads the latest build at
# runtime and keeps it updated. That keeps it in step with Discord's
# frequent client changes better than nixpkgs' pinned `vencord` would
# (`vencord.useSystem`). Vencord's plugins, themes and QuickCSS are also left
# mutable: setting `vencord.settings` here would make its settings file a
# read-only store symlink, and toggling plugins in the UI would stop saving.
{ ... }:
{
  flake.modules.homeManager.vesktop = {
    programs.vesktop.enable = true;
  };
}
