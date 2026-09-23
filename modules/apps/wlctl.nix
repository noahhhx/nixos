# The "wlctl" aspect: WiFi/VPN TUI for NetworkManager (station and AP modes,\n# WPA enterprise, VPN toggles, `wlctl doctor`). Requires the NetworkManager\n# service, enabled by the hosts that need it (see hardware/framework.nix).\n# Upstream flake — nixpkgs only has wlrctl, which is a different tool.\n# https://github.com/aashish-thapa/wlctl
{ inputs, ... }:
{
  flake.modules.homeManager.wlctl =
    { pkgs, ... }:
    {
      home.packages = [ inputs.wlctl.packages.${pkgs.system}.default ];
    };
}
