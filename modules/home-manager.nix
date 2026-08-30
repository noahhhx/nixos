{ config, inputs, lib, ... }: {
  options.homeManager.modules = lib.mkOption {
    type = lib.types.attrsOf lib.types.deferredModule;
    default = {};
  };

  # home-manager itself belongs to the base bag:
  config.nixos.modules.base = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];
    home-manager = {
      useGlobalPkgs = true;      # home-manager uses the system's nixpkgs
      useUserPackages = true;
      backupFileExtension = "hm-backup";  # unmanaged files get renamed, not clobbered
    };
  };
}