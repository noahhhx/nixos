{
  inputs,
  ...
}:
{
  flake.modules.nixos.framework = {
    imports = [ inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series ];

    hardware.graphics.enable = true;
    hardware.amdgpu.initrd.enable = true;

    services.power-profiles-daemon.enable = true;

    # The MT7925's throughput and latency degrade badly with powersave on.
    networking.networkmanager = {
      enable = true;
      wifi.powersave = false;
    };
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    # Overrides nixos-hardware's mkDefault true.
    services.fprintd.enable = false;

    services.fwupd.enable = true;

    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 100;
    };
  };
}
