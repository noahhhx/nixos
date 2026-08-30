# modules/networking.nix — the networking feature (base: every machine).
# NetworkManager owns Wi-Fi/ethernet; wpa_supplicant must be explicitly off
# (the NM module defines the option too, so this needs mkForce).
{ lib, ... }: {
  nixos.modules.base = {
    networking = {
      networkmanager.enable = true;
      wireless.enable = lib.mkForce false;
      firewall.enable = true;   # openssh opens its own port via its module
    };
  };
}
