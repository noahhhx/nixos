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
