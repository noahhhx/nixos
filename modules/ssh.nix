# modules/ssh.nix — how you'll reach the VM without typing in its console
{ ... }: {
  nixos.modules.base = {
    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = true;  # lab VM only — keys before the Framework
    };
  };
}
