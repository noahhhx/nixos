# The "dolphin" aspect: file manager. The NixOS side enables gvfs — the
# userspace virtual filesystem providing the trash can, MTP (phones) and
# network-filesystem locations in Dolphin; its gvfsd-* user services are
# D-Bus-activated per session.
{ ... }:
{
  flake.modules.nixos.dolphin = {
    services.gvfs.enable = true;
  };

  flake.modules.homeManager.dolphin =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.kdePackages.dolphin ];
    };
}
