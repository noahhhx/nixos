# The "base" aspect: minimal, hardware-agnostic defaults shared by every
# host that imports it. Hosts opt into further aspects (see modules/hosts/).
{ inputs, ... }:
{
  flake.modules.nixos.base = {
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # Hardlink identical store paths as they are built, instead of
      # relying on a separate `nix optimise` pass.
      auto-optimise-store = true;
    };

    # Weekly garbage collection keeping two weeks of generations: rollbacks
    # stay possible, but the store (system closures, docker images, devenv
    # shells) cannot grow unbounded.
    nix.gc = {
      automatic = true;
      dates = "weekly";
      persistent = true; # catch up after the machine was powered off
      options = "--delete-older-than 14d";
    };

    # Pin nixpkgs to this flake's input everywhere: the flake registry
    # (used by `nix shell nixpkgs#...` and `flake:nixpkgs`) and NIX_PATH
    # (`<nixpkgs>`), so ad-hoc commands resolve to the exact nixpkgs the
    # system is built from instead of some unrelated channel.
    nix.registry.nixpkgs.flake = inputs.nixpkgs;
    nix.nixPath = [ "nixpkgs=flake:nixpkgs" ];

    # Firewall: make NixOS's default-deny inbound policy an explicit
    # definition so it cannot be silently lost. No aspect currently opens
    # an inbound port (this machine accepts no connections); the tailnet
    # is exempted by the "tailscale" aspect's trustedInterfaces.
    networking.firewall.enable = true;

    # Host-agnostic location settings (default locale/keymap are already
    # en_US.UTF-8 / us).
    time.timeZone = "Europe/London";
  };
}
