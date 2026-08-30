# modules/computers/vm.nix — a computer is just an assembly point:
# it picks bags of features and adds machine-specific bits
{ config, ... }: {
  nixos.configurations.vm = {
    imports = with config.nixos.modules; [ base workstation ]
      ++ [ (import ../../hardware/vm.nix) ];
    networking.hostName = "vm";
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    time.timeZone = "UTC";
  };
}
