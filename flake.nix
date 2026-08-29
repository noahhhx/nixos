{
    description = "beep boop computer start";

    inputs = {
        nixpkgs.url = "nixpkgs/nixos-26.05";
        home-manager = {
            url = "github:nix-community/home-manager/release-26.05";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = { self, nixpkgs, home-manager, ... }:
        let
            lib = nixpkgs.lib;
            hosts = {
                fw13 = {
                    system = "x86_64-linux";
                    homeManagerUser = "fw13";
                };
            };
        in
        {
            nixosConfigurations = builtins.listToAttrs (lib.mapAttrsToList (name: cfg: {
                inherit name;
                value = nixpkgs.lib.nixosSystem {
                    system = cfg.system;
                    modules = [
                        ./hosts/${name}/configuration.nix
                        home-manager.nixosModules.home-manager
                        {
                            home-manager = {
                                useGlobalPkgs = true;
                                useUserPackages = true;
                                users.${cfg.homeManagerUser} = import ./hosts/${name}/home.nix;
                                backupFileExtension = "backup";
                            };
                        }
                    ];
                };
            }) hosts);
        };
}