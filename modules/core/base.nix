{ inputs, ... }:
{
  flake.modules.nixos.base = {
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };

    nix.gc = {
      automatic = true;
      dates = "weekly";
      persistent = true;
      options = "--delete-older-than 14d";
    };

    nix.registry.nixpkgs.flake = inputs.nixpkgs;
    nix.nixPath = [ "nixpkgs=flake:nixpkgs" ];

    networking.firewall.enable = true;

    time.timeZone = "Europe/London";
  };
}
