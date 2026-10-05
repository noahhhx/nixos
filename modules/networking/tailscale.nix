{ ... }:
let
  operator = "noah";
in
{
  flake.modules.nixos.tailscale = {
    services.tailscale = {
      enable = true;
      extraSetFlags = [ "--operator=${operator}" ];
    };

    networking.firewall.trustedInterfaces = [ "tailscale0" ];
  };

  flake.modules.homeManager.tailscale =
    { config, ... }:
    {
      services.trayscale.enable = true;
      home.packages = [ config.services.trayscale.package ];
    };
}
