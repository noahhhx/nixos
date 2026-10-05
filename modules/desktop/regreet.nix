# Gotchas this file deliberately avoids (regreet 0.3.0):
#   - CSS widget names are the relm4 `#[name = ...]` ones from regreet's
#     templates.rs: #background (the wallpaper picture), #clock_frame,
#     #message_label, #login_button, #cancel_button, #user_toggle,
#     #sess_toggle, #error_info. The login box and clock frame also carry
#     the "background" CSS class, so `frame.background` targets them
#     without also catching the window.
#   - The login panel's contents are a `gtk::Grid` with a hardcoded
#     width-request of 500 and 15px margins/spacing (see templates.rs), so
#     the scale is fixed in Rust. CSS `min-width`/`padding` on the grid
#     node (there is exactly one grid in the greeter) is the only way to
#     make the panel bigger and roomier.
{ ... }:
{
  flake.modules.nixos.regreet =
    { pkgs, ... }:
    {
      programs.regreet = {
        enable = true;

        settings = {
          background = {
            path = "${./hyprpaper/wallpaper.png}";
            fit = "Cover";
          };

          GTK.application_prefer_dark_theme = true;

          widget.clock = {
            format = "%H:%M";
            resolution = "60s";
          };
        };

        font = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font";
          size = 16;
        };

        cursorTheme = {
          package = pkgs.vanilla-dmz;
          name = "DMZ-Black";
        };

        extraCss = ''
          window {
            background-color: rgba(15, 15, 15, 1.0);
          }

          #background {
            opacity: 0.35;
          }

          frame.background {
            background-color: rgba(15, 15, 15, 0.92);
            border: 1px solid rgba(255, 255, 255, 0.25);
            border-radius: 0;
          }

          grid {
            padding: 48px 64px 40px;
            min-width: 700px;
          }

          /* The clock is pinned to the top (valign Start is hardcoded in regreet's
             Rust, and GTK4 CSS has no percentage margins), so a fixed
             margin-top walks it down to sit a phone-sized gap above the
             vertically centered login panel. Tuned for the internal
             2256x1504 panel (panel top ~542px, label ~187px at 160pt,
             so a ~300px margin leaves ~55px of air). */
          #clock_frame {
            margin-top: 300px;
            background-color: transparent;
            border-style: none;
          }
          #clock_frame label {
            color: rgba(245, 224, 220, 1.0);
            font-size: 160px;
          }

          frame.background label {
            color: rgba(166, 173, 200, 1.0);
          }
          #message_label {
            color: rgba(88, 91, 112, 1.0);
          }

          entry,
          combobox button {
            background-color: rgba(15, 15, 15, 1.0);
            color: rgba(205, 214, 244, 1.0);
            caret-color: rgba(245, 224, 220, 1.0);
            border-style: solid;
            border-width: 0 0 1px 0;
            border-color: transparent;
            border-bottom-color: rgba(255, 255, 255, 0.25);
            border-radius: 0;
            min-height: 52px;
            min-width: 420px;
            padding: 0 12px 0 16px;
          }
          entry:focus,
          combobox button:hover {
            border-bottom-color: rgba(203, 166, 247, 1.0);
          }
          entry image {
            color: rgba(88, 91, 112, 1.0);
          }
          entry image:hover {
            color: rgba(166, 173, 200, 1.0);
          }
          combobox arrow {
            color: rgba(88, 91, 112, 1.0);
          }

          popover {
            background-color: rgba(15, 15, 15, 1.0);
            border: 1px solid rgba(255, 255, 255, 0.25);
            border-radius: 0;
            padding: 8px;
          }
          popover listview row {
            min-height: 48px;
            padding: 0 16px;
          }
          popover listview row:selected {
            background-color: rgba(203, 166, 247, 0.25);
            color: rgba(205, 214, 244, 1.0);
          }

          button {
            border-radius: 0;
          }

          #cancel_button {
            background-color: transparent;
            color: rgba(166, 173, 200, 1.0);
            border-style: none;
            padding: 14px 36px;
          }
          #cancel_button:hover {
            color: rgba(205, 214, 244, 1.0);
            background-color: rgba(255, 255, 255, 0.06);
          }

          #login_button {
            background-color: rgba(203, 166, 247, 1.0);
            color: rgba(15, 15, 15, 1.0);
            border-style: none;
            padding: 14px 48px;
          }
          #login_button:hover {
            background-color: rgba(180, 190, 254, 1.0);
          }

          button.destructive-action {
            background-color: transparent;
            color: rgba(166, 173, 200, 1.0);
            border-style: none;
            padding: 12px 32px;
          }
          button.destructive-action:hover {
            color: rgba(205, 214, 244, 1.0);
            background-color: rgba(255, 255, 255, 0.06);
          }

          #user_toggle,
          #sess_toggle {
            background-color: transparent;
            border-style: none;
            color: rgba(88, 91, 112, 1.0);
            min-height: 52px;
          }
          #user_toggle:hover,
          #user_toggle:checked,
          #sess_toggle:hover,
          #sess_toggle:checked {
            color: rgba(203, 166, 247, 1.0);
          }

          infobar {
            background-color: rgba(15, 15, 15, 0.95);
            border-style: none;
          }
          infobar button {
            background-color: transparent;
            border-style: none;
            color: rgba(243, 139, 168, 1.0);
          }
          #error_label {
            color: rgba(243, 139, 168, 1.0);
          }

          scrollbar {
            background-color: transparent;
            border-style: none;
          }
          scrollbar slider {
            background-color: rgba(88, 91, 112, 0.6);
            border-radius: 0;
            min-width: 6px;
          }
        '';
      };
    };
}
