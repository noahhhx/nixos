{
  inputs,
  ...
}:
{
  flake.modules.nixos.devenv = {
    imports = [
      # Prebuilt index; building one from scratch takes hours.
      inputs.nix-index-database.nixosModules.nix-index
    ];

    nix.settings = {
      substituters = [
        "https://devenv.cachix.org"
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];

      # Recommended by nix-direnv: keeps direnv-cached dev shells valid across GC.
      keep-outputs = true;
      keep-derivations = true;
    };

    programs.nix-ld.enable = true;

    programs.nix-index-database.comma.enable = true;
  };

  flake.modules.homeManager.devenv =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.devenv ];

      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
    };
}
