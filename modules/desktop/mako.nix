{ ... }:
{
  flake.modules.homeManager.mako = {
    services.mako = {
      enable = true;
      settings = {
        default-timeout = 8000;
        max-history = 100;

        font = "JetBrainsMono Nerd Font 10";
        anchor = "top-right";
        margin = "10";
        padding = "12,16";
        width = 360;
        height = 160;

        border-size = 2;
        border-radius = 0;
        background-color = "#1e1e2ef2";
        text-color = "#cdd6f4";
        border-color = "#cba6f7";
        progress-color = "over #45475a";

        format = ''<span size="small" color="#7f849c">%a</span>\n<b><span color="#cba6f7">%s</span></b>\n%b'';

        max-icon-size = 32;
      };
    };

    services.mako.extraConfig = ''
      [urgency=low]
      text-color=#a6adc8
      border-color=#585b70
      format=<span size="small" color="#7f849c">%a</span>\n<b>%s</b>\n%b

      [urgency=critical]
      default-timeout=0
      border-color=#f38ba8
      format=<span size="small" color="#7f849c">%a</span>\n<b><span color="#f38ba8">%s</span></b>\n%b
    '';
  };
}
