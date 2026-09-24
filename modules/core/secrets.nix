# The age key is generated on first activation and not reproducible: a fresh
# reinstall gets a new identity whose public key must be re-added to the
# secrets file.
{
  inputs,
  ...
}:
{
  flake.modules.nixos.secrets = {
    imports = [ inputs.sops-nix.nixosModules.sops ];

    sops.age = {
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };
  };
}
