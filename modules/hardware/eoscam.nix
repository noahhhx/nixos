{ inputs, ... }:
{
  flake.modules.nixos.eoscam = {
    imports = [ inputs.eoscam.nixosModules.default ];

    services.eoscam.enable = true;
  };
}
