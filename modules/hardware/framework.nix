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

    services.fprintd.enable = false;

    services.fwupd.enable = true;

    services.udev.extraRules = ''
      # The Logitech USB receiver in the EPOMAKER keyboard's USB passthrough
      # port wakes the laptop seconds after every suspend. It is not allowed to
      # wake the machine.
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{idProduct}=="c547", ATTR{power/wakeup}="disabled"
    '';

    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 100;
    };
  };
}
