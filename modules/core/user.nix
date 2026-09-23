# The "user" aspect: the primary interactive user account — the single
# place the username is defined on the NixOS side (keep in sync with
# `home-manager.users.<name>` in modules/hosts/; everything else derives
# it from here).
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
