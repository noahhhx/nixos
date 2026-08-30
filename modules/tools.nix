# modules/tools.nix — the "baseline CLI tools" feature (base: every machine gets it)
{ ... }: {
  # note: the value is a FUNCTION — deferred modules are evaluated by NixOS itself,
  # so pkgs comes from the lower level, not from this top-level module.
  # mightyiam's users.nix uses the same trick.
  nixos.modules.base = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.git ];
  };
}
