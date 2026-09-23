# The "ssh" aspect: the ssh client, managed by home-manager. This machine
# never accepts ssh connections — no daemon, no authorized keys, nothing
# published — the aspect only configures reaching *other* machines.
#
# Tailscale MagicDNS names (*.ts.net) default to the local username, so
# `ssh somehost.ts.net` just works for tailnet machines with the same user.
# The username is read from home-manager itself — no sync needed with
# modules/core/user.nix.
{ ... }:
{
  flake.modules.homeManager.ssh =
    { config, ... }:
    {
      programs.ssh = {
        enable = true;
        settings."*.ts.net".user = config.home.username;
      };
    };
}
