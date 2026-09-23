# The "docker" aspect: the Docker daemon and CLI. Every normal user is in
# the "docker" group for passwordless access — note that this is
# root-equivalent (docker.sock grants host root), the standard trade-off
# for a single-user dev machine. For stricter isolation switch to
# `virtualisation.docker.rootless` instead.
{ ... }:
{
  flake.modules.nixos.docker =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      virtualisation.docker.enable = true;

      # Compose v2, as both the classic `docker-compose` command and the
      # `docker compose` subcommand (the CLI finds the plugin under the
      # profile's libexec/docker/cli-plugins).
      environment.systemPackages = [ pkgs.docker-compose ];

      # Docker group membership for whichever normal user(s) the host
      # defines (no username hardcoding — see modules/core/user.nix);
      # via group members rather than users.users.<name>.extraGroups so
      # the group can be filled without redefining the user set it reads.
      users.groups.docker.members = lib.filter (u: config.users.users.${u}.isNormalUser or false) (
        lib.attrNames config.users.users
      );
    };
}
