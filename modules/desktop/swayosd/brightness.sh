# swayosd-brightness raise|lower: step the backlight 5% and show swayosd's OSD.
#
# `swayosd-client --brightness` makes swayosd-server fork brightnessctl four
# times per press on its GTK main thread (~25-40ms), which at Hyprland's 40Hz
# key repeat keeps the main loop busy so the OSD never redraws while a
# brightness key is held. Doing the change here, outside the server, leaves it
# only a cheap custom-progress redraw, like the in-process volume path.
#
# Same arithmetic as swayosd's brightnessctl backend: a rounded 5%-of-max
# step, clamped to [5%, 100%] so the panel never goes fully dark.

IFS=, read -r _ _ cur _ max < <(brightnessctl --machine-readable)
step=$(((max * 5 + 50) / 100))

case "${1:-}" in
raise) new=$((cur + step > max ? max : cur + step)) ;;
lower) new=$((cur - step < step ? step : cur - step)) ;;
*)
  echo "usage: swayosd-brightness raise|lower" >&2
  exit 64
  ;;
esac

brightnessctl --quiet set "$new"

frac=$((new * 10000 / max))
swayosd-client \
  --custom-icon display-brightness-symbolic \
  --custom-progress "$(printf '%d.%04d' $((frac / 10000)) $((frac % 10000)))" \
  --custom-progress-text "$(printf '%3d%%' $(((new * 100 + max / 2) / max)))"
