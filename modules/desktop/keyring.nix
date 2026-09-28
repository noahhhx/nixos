# A secrets provider for the session. Clients talk to the D-Bus
# `org.freedesktop.secrets` service (libsecret, e.g. GitHub Desktop's bundled
# keytar stores its OAuth token there); without a provider the token can't be
# persisted and every push needs a fresh sign-in.
#
# Ubuntu ships gnome-keyring by default, which is why this only bites here.
{ ... }:
{
  flake.modules.nixos.keyring = {
    services.gnome.gnome-keyring.enable = true;

    # Unlock the login keyring at graphical login so clients don't get
    # prompted. greetd authenticates tuigreet logins through this PAM
    # service; pam_gnome_keyring works under greetd's root worker: it drops
    # to the PAM user's uid before starting the daemon, unlocks the keyring
    # with the auth password, and exports GNOME_KEYRING_CONTROL back into
    # the PAM env, which greetd passes on to the session.
    security.pam.services.greetd.enableGnomeKeyring = true;
  };
}
