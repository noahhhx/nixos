# modules/computers/framework.nix — the Framework 13 assembly point:
# base + workstation bags, the nixos-hardware module for the AMD silicon,
# and laptop-isms.
{ config, inputs, ... }: {
  nixos.configurations.framework = {
    imports =
      with config.nixos.modules;
      [ base workstation ]
      ++ [
        inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
        (import ../../hardware/framework.nix)
      ];
    networking.hostName = "framework";
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    system.stateVersion = "26.05";   # don't bump this on existing systems
    # laptop-isms — verify each on search.nixos.org (that's the exercise):
    services.fwupd.enable = true;       # firmware/BIOS updates
    hardware.bluetooth.enable = true;   # Bluetooth radio
    services.fprintd.enable = true;     # fingerprint reader (power button)
  };
}
