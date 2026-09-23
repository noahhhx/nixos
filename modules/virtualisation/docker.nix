# The "docker" aspect: the Docker daemon and CLI. The primary user is in
# the "docker" group for passwordless access — note that this is
# root-equivalent (docker.sock grants host root), the standard trade-off
# for a single-user dev machine. For stricter isolation switch to
# `virtualisation.docker.rootless` instead.
{ ... }:
{
  flake.modules.nixos.docker =
    { pkgs, ... }:
    {
      virtualisation.docker.enable = true;

      # Compose v2, as both the classic `docker-compose` command and the
      # `docker compose` subcommand (the CLI finds the plugin under the
      # profile's libexec/docker/cli-plugins).
      environment.systemPackages = [ pkgs.docker-compose ];

      # Keep the username in sync with modules/core/user.nix.
      users.users.noah.extraGroups = [ "docker" ];
    };
}
