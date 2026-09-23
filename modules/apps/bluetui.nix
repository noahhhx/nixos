# The "bluetui" aspect: TUI for managing Bluetooth devices/connections over\n# bluez. Requires the Bluetooth service, enabled by the hosts that need it\n# (see hardware/framework.nix). https://github.com/pythops/bluetui
{ ... }:
{
  flake.modules.homeManager.bluetui =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.bluetui ];
    };
}
