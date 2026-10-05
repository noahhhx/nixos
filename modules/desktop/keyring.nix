{ ... }:
{
  flake.modules.nixos.keyring = {
    services.gnome.gnome-keyring.enable = true;

    security.pam.services.greetd.enableGnomeKeyring = true;
  };
}
