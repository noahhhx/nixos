{ config, ... }:
let
  inherit (config.flake.modules) nixos homeManager;
in
{
  hosts.default = {
    imports = [
      nixos.desktop
      ./_facts/default.nix
    ];

    home-manager.users.noah = {
      home.stateVersion = "26.05";
      imports = [ homeManager.desktop ];
    };

    networking.hostName = "default";
    nixpkgs.hostPlatform = "x86_64-linux";
    system.stateVersion = "26.05";
  };
}
