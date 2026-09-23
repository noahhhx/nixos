# The "docker" aspect: the Docker daemon and CLI. The primary user is in
# the "docker" group for passwordless access — note that this is
# root-equivalent (docker.sock grants host root), the standard trade-off
# for a single-user dev machine. For stricter isolation switch to
# `virtualisation.docker.rootless` instead.
{ ... }:
{
  flake.modules.nixos.docker = {
    virtualisation.docker.enable = true;

    # Keep the username in sync with modules/core/user.nix.
    users.users.noah.extraGroups = [ "docker" ];
  };
}
