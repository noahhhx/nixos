# modules/audio.nix — the audio feature: PipeWire (the modern standard) on
# every workstation. rtkit lets the audio server claim real-time priority.
{ ... }: {
  nixos.modules.workstation = {
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;   # PulseAudio compatibility for the vast app majority
    };
  };
}
