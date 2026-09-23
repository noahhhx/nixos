# The "mako" aspect: the notification daemon for Wayland sessions. It
# collects the notifications the rest of the stack emits (hyprshot's
# "saved to clipboard" toast, NetworkManager/wlctl WiFi results, bluetui
# pairing, battery low, ...) and shows them as popups; `makoctl` manages
# them (dismiss, restore history) at runtime.
#
# home-manager installs the config and registers mako with the session's
# D-Bus — the daemon itself is D-Bus-activated on the first notification of
# the session, so it needs no systemd user unit of its own.
# https://github.com/emersion/mako
{ ... }:
{
  flake.modules.homeManager.mako = {
    services.mako = {
      enable = true;
      settings = {
        # Dismiss notifications automatically after 8 seconds; errors stay
        # until dismissed (their own timeout=0 takes precedence).
        default-timeout = 8000;
        # Keep closed notifications in history for `makoctl restore`.
        max-history = 100;
      };
    };

    # "urgency=critical" (errors) never time out on their own.
    services.mako.extraConfig = ''
      [urgency=critical]
      default-timeout=0
    '';
  };
}
