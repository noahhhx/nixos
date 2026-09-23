# The "tailscale" aspect: mesh VPN (tailnet) via the tailscaled daemon.
#
# Down by default: the daemon is installed but not started at boot, so the
# machine only joins the tailnet when the user brings it up:
#   sudo systemctl start tailscaled
#   sudo tailscale up
# Connection state also persists (`tailscale down` survives restarts), so the
# node stays off the tailnet until explicitly told otherwise.
{ lib, ... }:
{
  flake.modules.nixos.tailscale = {
    services.tailscale.enable = true;

    # Runtime opt-in instead of boot autostart.
    systemd.services.tailscaled.wantedBy = lib.mkForce [ ];

    # Tailnet traffic should never be filtered by the local firewall
    # (default-deny, explicitly enabled by the "base" aspect).
    networking.firewall.trustedInterfaces = [ "tailscale0" ];
  };
}
