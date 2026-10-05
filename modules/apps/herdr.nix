{ inputs, ... }:
{
  flake.modules.homeManager.herdr =
    { pkgs, ... }:
    {
      home.packages = [
        inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
        pkgs.libnotify
      ];

      xdg.configFile."herdr/config.toml".source = (pkgs.formats.toml { }).generate "herdr-config.toml" {
        onboarding = false;
        theme.name = "terminal";
        ui.toast.delivery = "system";
      };
    };
}
