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

      environment.systemPackages = [ pkgs.docker-compose ];

      users.groups.docker.members = lib.filter (u: config.users.users.${u}.isNormalUser or false) (
        lib.attrNames config.users.users
      );
    };
}
