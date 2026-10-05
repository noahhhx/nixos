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
