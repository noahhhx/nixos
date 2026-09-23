# The "home-manager" aspect: wires home-manager into NixOS hosts so that
# feature files can contribute `flake.modules.homeManager.<aspect>` modules,
# which hosts compose per user (see modules/hosts/).
{ inputs, ... }:
{
  flake.modules.nixos.home-manager = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-backup";
    };
  };
}
