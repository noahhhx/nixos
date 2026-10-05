# tailscaled starts at boot, but whether the node joins the tailnet persists
# across restarts: after `tailscale down` (or disconnecting in trayscale) it
# stays off until brought back up.
#
# Trayscale sits in the waybar tray as the GUI. It needs the user to be the
# tailscale operator to change state without root.
{ ... }:
let
  operator = "noah";
in
{
  flake.modules.nixos.tailscale = {
    services.tailscale = {
      enable = true;
      extraSetFlags = [ "--operator=${operator}" ];
    };

    networking.firewall.trustedInterfaces = [ "tailscale0" ];
  };

  flake.modules.homeManager.tailscale =
    { config, ... }:
    {
      services.trayscale.enable = true;
      # The service runs trayscale from the store; put it on PATH too so the
      # window (and its desktop entry, for walker) can be opened by hand.
      home.packages = [ config.services.trayscale.package ];
    };
}
