# The "user" aspect: the primary interactive user account.
# Keep the username in sync with the home-manager composition in hosts.nix.
{ ... }:
{
  flake.modules.nixos.user = {
    users.users.noah = {
      isNormalUser = true;
      description = "Noah";
      extraGroups = [
        "wheel" # sudo
        "video" # backlight / video devices
        "input" # input devices (e.g. for tools reading libinput)
      ];
      # Placeholder so greetd login works out of the box; change with `passwd`.
      initialPassword = "nixos";
    };
  };
}
