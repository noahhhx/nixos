{ ... }:
{
  flake.modules.homeManager.mako = {
    services.mako = {
      enable = true;
      settings = {
        default-timeout = 8000;
        max-history = 100;
      };
    };

    services.mako.extraConfig = ''
      [urgency=critical]
      default-timeout=0
    '';
  };
}
