# The "audio" aspect: PipeWire as the sound server (ALSA, PulseAudio and
# JACK compatibility in one; handles Bluetooth audio together with the
# bluetooth aspect's bluez). All NixOS-side.
{ ... }:
{
  flake.modules.nixos.audio = {
    # Realtime scheduling for the audio server.
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };
  };
}
