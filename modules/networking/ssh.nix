# The "ssh" aspect: the ssh client, managed by home-manager. This machine
# never accepts ssh connections — no daemon, no authorized keys, nothing
# published — the aspect only configures reaching *other* machines.
#
# Tailscale MagicDNS names (*.ts.net) default to the local username, so
# `ssh somehost.ts.net` just works for tailnet machines with the same user.
# Keep the username in sync with modules/core/user.nix.
{ ... }:
{
  flake.modules.homeManager.ssh = {
    programs.ssh = {
      enable = true;
      settings."*.ts.net".user = "noah";
    };
  };
}
