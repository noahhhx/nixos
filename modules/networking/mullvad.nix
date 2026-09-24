# While a mullvad tunnel is up, mullvad-daemon owns DNS and firewall policy;
# bring tailscale up with `tailscale up --accept-dns=false` to stop the two
# fighting over /etc/resolv.conf.
{ ... }:
{
  flake.modules.nixos.mullvad =
    { pkgs, ... }:
    {
      services.mullvad-vpn = {
        enable = true;
        package = pkgs.mullvad-vpn;
      };
    };
}
