# The "secrets" aspect: encrypted secrets via sops-nix, decrypted on the
# host at activation/boot. Nothing plaintext in the repo, nothing typed at
# rebuild time.
#
# Key model: a dedicated age key per host at /var/lib/sops-nix/key.txt,
# generated automatically on first activation if missing (generateKey
# below), so no extra key management and no dependency on an sshd host key
# (this machine runs no ssh daemon — see the "ssh" aspect). The key is not
# reproducible: a fresh reinstall gets a new identity and its new public
# key must be added to the secrets file.
#
# Bootstrap (adding the first secret):
#   1. Print this host's age public key (after the first switch, which
#      generates the key):
#        sudo nix shell nixpkgs#age -- age-keygen -y /var/lib/sops-nix/key.txt
#   2. Create modules/core/secrets.yaml encrypted to that key (and any
#      other hosts' keys that should share the secret):
#        nix shell nixpkgs#sops -- sops --age age1... modules/core/secrets.yaml
#      A .sops.yaml at the repo root can pin that key set for the repo.
#   3. Wire it up in this module (sops.defaultSopsFile = ./secrets.yaml;
#      sops.secrets.<name> = { };) and point consumers at
#      config.sops.secrets.<name>.path.
#   4. git add the encrypted file — nix only sees git-tracked files.
{
  inputs,
  ...
}:
{
  flake.modules.nixos.secrets = {
    imports = [ inputs.sops-nix.nixosModules.sops ];

    sops.age = {
      keyFile = "/var/lib/sops-nix/key.txt";
      # Create the key on first activation so a host is decrypt-capable
      # out of the box.
      generateKey = true;
    };
  };
}
