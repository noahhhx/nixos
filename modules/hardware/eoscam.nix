# The "eoscam" aspect: a Canon EOS camera (550D) as a webcam.
#
# The upstream module loads v4l2loopback as "EOS Webcam" and runs the eoscam
# daemon as a user service. The device shows black until the camera is
# plugged in and switched on, then streams liveview; apps keep their stream
# across the camera coming and going. eoscam kills gvfs's gphoto2 monitor
# (the dolphin aspect enables gvfs) when it holds the camera.
{ inputs, ... }:
{
  flake.modules.nixos.eoscam = {
    imports = [ inputs.eoscam.nixosModules.default ];

    services.eoscam.enable = true;
  };
}
