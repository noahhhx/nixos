# The "regreet" aspect: the graphical greetd greeter.
#
# tuigreet (the previous greeter) was a plain ncurses TUI with no theming
# hooks, so the login screen couldn't match the desktop. ReGreet is a GTK4
# greeter that runs under cage (a kiosk compositor) and is styled entirely
# with CSS, letting it follow the rest of the desktop's look: flat (no
# rounding, no shadows), hairline straight borders, the #0f0f0f dark base,
# Catppuccin Mocha accents and JetBrainsMono Nerd Font - the login-screen
# twin of hyprlock.
#
# Layout (cage is fullscreen, so this is the whole screen):
#
#     HH:MM                               <- clock, huge, rose - phone
#                                        |   lock-screen style, a short gap
#          |  User      noah             |    <- login box, centered: one
#          |  Session   Hyprland (uwsm-managed) |   bordered panel; the
#          |  Password  ............    |    fields inside carry only a
#          |                    Login   |    hairline underline, not boxes
#
#     Reboot   Power Off                  <- quiet text, bottom center
#
# The aesthetic: exactly one rectangle on screen (the login panel, with
# generous padding), and no borders inside it - fields sit on the panel and
# are separated by a 1px underline each, so it reads as straight lines
# rather than a stack of blocks. The only solid fill is the mauve Login
# button, which anchors the whole screen.
#
# The background is the desktop's wallpaper (shared with the hyprpaper
# aspect), dimmed to a third via CSS opacity - the greeter's equivalent of
# hyprlock's dimmed live screenshot.
#
# Sessions come from the wayland-sessions desktop files the hyprland package
# provides. The entry to pick is "Hyprland (uwsm-managed)"
# (hyprland-uwsm.desktop, provided because programs.hyprland.withUWSM);
# its Exec carries `uwsm start -e -D Hyprland hyprland.desktop`, which is
# what the old tuigreet --cmd spelled out directly. ReGreet caches the last
# used session per user in /var/lib/regreet, so it only ever has to be
# picked once; the plain "Hyprland" entry (no uwsm: no session units, no
# autostart) must stay unpicked.
#
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
#   - The plain hyprland session desktop file can't be hidden (no NoDisplay
#     flag, and nixpkgs offers no session exclusion), so both entries show.
{ ... }:
{
  flake.modules.nixos.regreet =
    { pkgs, ... }:
    {
      programs.regreet = {
        enable = true;

        settings = {
          # The desktop's own wallpaper, dimmed by CSS (see extraCss), so
          # login screen and desktop look continuous.
          background = {
            path = "${./hyprpaper/wallpaper.png}";
            fit = "Cover";
          };

          # Dark by default, like everything else on this desktop.
          GTK.application_prefer_dark_theme = true;

          # The huge rose HH:MM, like hyprlock's clock. JetBrainsMono is
          # monospace, so every update renders at the same width and the
          # clock never jitters (the default label_width padding exists to
          # hide jitter for proportional fonts, not needed here).
          widget.clock = {
            format = "%H:%M";
            resolution = "60s";
          };
        };

        # JetBrainsMono Nerd Font, like kitty and hyprlock. 16pt: the
        # greeter is seen from across the room, not at desk distance.
        font = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font";
          size = 16;
        };

        # The same cursor as the session (the "cursor" aspect).
        cursorTheme = {
          package = pkgs.vanilla-dmz;
          name = "Vanilla-DMZ";
        };

        # The rice itself, layered on top of the Adwaita-dark GTK theme.
        # Selector names are regreet's widget names; see the header comment.
        # Design rules: no rounding, no shadows, borders only where they
        # separate things (panel edge, field underline) - never around
        # every widget, which is what makes a theme feel blocky.
        extraCss = ''
          /* Everything regreet doesn't style sits on this base. */
          window {
            background-color: rgba(15, 15, 15, 1.0);
          }

          /* Dim the wallpaper to a third, like hyprlock's dimmed
             screenshot, letting the flat base show through. */
          #background {
            opacity: 0.35;
          }

          /* The login panel: the one rectangle on screen. Darker than
             the dimmed wallpaper so it stands out without needing a heavy
             border; a quarter-transparent hairline frames it. */
          frame.background {
            background-color: rgba(15, 15, 15, 0.92);
            border: 1px solid rgba(255, 255, 255, 0.25);
            border-radius: 0;
          }

          /* The grid inside the panel: roomier and wider than the 500px
             hardcoded in regreet's Rust (see header comment). */
          grid {
            padding: 48px 64px 40px;
            min-width: 700px;
          }

          /* Clock: borderless, huge, rose - the kitty cursor color,
             same as hyprlock's clock. Phone lock-screen style: the clock
             is pinned to the top (valign Start is hardcoded in regreet's
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

          /* Row labels ("User:", "Session:", "Password:"): subtext1. */
          frame.background label {
            color: rgba(166, 173, 200, 1.0);
          }
          /* Greeting / status messages: quiet, like hyprlock's greeting. */
          #message_label {
            color: rgba(88, 91, 112, 1.0);
          }

          /* Entries and combo boxes: no boxes - the panel is their
             background - just a hairline underline each, which lights up
             mauve on focus, the way hyprlock's input field reacts to auth
             state. min-width stretches the grid's entry column. */
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
          /* The password entry's peek eye. */
          entry image {
            color: rgba(88, 91, 112, 1.0);
          }
          entry image:hover {
            color: rgba(166, 173, 200, 1.0);
          }
          combobox arrow {
            color: rgba(88, 91, 112, 1.0);
          }

          /* Dropdown popovers: the same flat panel, roomy rows. */
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

          /* Flat buttons everywhere. */
          button {
            border-radius: 0;
          }

          /* Cancel: quiet text on the panel, no box; hover washes a
             faint grey. */
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

          /* Login: the only solid fill on the screen - the mauve accent,
             kitty's active tab (dark text on purple). Hover shifts to
             Catppuccin lavender. */
          #login_button {
            background-color: rgba(203, 166, 247, 1.0);
            color: rgba(15, 15, 15, 1.0);
            border-style: none;
            padding: 14px 48px;
          }
          #login_button:hover {
            background-color: rgba(180, 190, 254, 1.0);
          }

          /* Reboot / Power Off: quiet subtext on the dimmed wallpaper, no
             boxes - exactly like #cancel_button, down to the hover wash.
             (Red read as "danger" for buttons that merely restart the
             machine; the red fail state stays reserved for errors.) */
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

          /* The manual-entry toggles: quiet icons, mauve when active. */
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

          /* Error banner ("Incorrect password" etc.): no frame - a dark
             strip carrying the red fail state. */
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

          /* Scrollbars in the session/user lists: thin dark sliders. */
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
