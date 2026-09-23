# The "base" aspect: minimal, hardware-agnostic defaults shared by every
# host that imports it. Hosts opt into further aspects (see hosts.nix).
{
  flake.modules.nixos.base = {
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}
