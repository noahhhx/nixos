# The "mullvad" aspect: Mullvad VPN daemon, CLI (`mullvad`) and GUI
# (`mullvad-vpn`). The daemon starts unconnected and forwards nothing until a
# relay is picked in the GUI / CLI.
#
# Coexisting with tailscale (also enabled on hosts that import this aspect):
# mullvad-daemon owns DNS and firewall policy while a tunnel is up, so bring
# tailscale up with `tailscale up --accept-dns=false` to stop the two fighting
# over /etc/resolv.conf.
{ ... }:
{
  flake.modules.nixos.mullvad =
    { pkgs, ... }:
    {
      services.mullvad-vpn = {
        enable = true;
        # `pkgs.mullvad` (the default) is CLI-only; `mullvad-vpn` also ships
        # the desktop app.
        package = pkgs.mullvad-vpn;
      };
    };
}
