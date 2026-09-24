# tailscaled connection state persists across restarts, so the node stays off
# the tailnet until explicitly brought up.
{ lib, ... }:
{
  flake.modules.nixos.tailscale = {
    services.tailscale.enable = true;

    systemd.services.tailscaled.wantedBy = lib.mkForce [ ];

    networking.firewall.trustedInterfaces = [ "tailscale0" ];
  };
}
