# Month calendar behind the waybar clock, drawn in the bar's own palette
# (./style.css). h/l or ←/→ step a month, H/L a year, t jumps back to today,
# q/Esc or clicking outside closes. Weeks start on Monday and carry ISO week numbers, matching
# the clock's former `W%V` alt format.

bg='#1b1b1b'
text=$'\e[38;2;198;198;198m'     # #c6c6c6: bar text
dim=$'\e[38;2;110;110;110m'      # #6e6e6e: inactive workspaces
weekend=$'\e[38;2;158;158;158m'  # #9e9e9e
bright=$'\e[1;38;2;245;245;245m' # #f5f5f5: active workspace
today=$'\e[1;38;2;27;27;27;48;2;245;245;245m'
reset=$'\e[0m'
width=23 # 2-digit week number, then 7 days of " dd"

# Paint the whole window in the bar's background, hide the cursor, and have
# kitty report focus changes (\e[I in, \e[O out).
printf '\e]11;%s\e\\\e[?25l\e[?1004h' "$bg"

# Losing focus closes the popup, so a click anywhere else dismisses it. With
# the default focus-follows-mouse, merely hovering another window would do
# the same, so focus is click-only while the popup is open (hovering from a
# floating window to a tiled one refocuses too unless
# float_switch_override_focus is 0). The previous values are put back on
# exit; closing the kitty window sends HUP, the waybar toggle sends TERM.
option() { hyprctl getoption "input:$1" | sed -n 's/^int: //p'; }
follow_mouse=$(option follow_mouse || true)
float_switch=$(option float_switch_override_focus || true)
set_focus() {
  hyprctl eval "hl.config({ input = { follow_mouse = $1, float_switch_override_focus = $2 } })" >/dev/null || true
}
if [[ -n $follow_mouse && -n $float_switch ]]; then
  set_focus 2 0
  trap 'set_focus "$follow_mouse" "$float_switch"' EXIT
fi
trap exit HUP TERM INT

this_month() {
  year=$(date +%Y)
  month=$(date +%-m)
}

shift_month() {
  local m=$((year * 12 + month - 1 + $1))
  year=$((m / 12))
  month=$((m % 12 + 1))
}

draw() {
  local first offset days start now title pad name week n line r c
  local rows cols x y
  local -a lines
  first=$(printf '%04d-%02d-01' "$year" "$month")
  offset=$(($(date -d "$first" +%u) - 1))
  days=$(date -d "$first +1 month -1 day" +%-d)
  start=$(date -d "$first -$offset days" +%F)
  now=$(date +%F)

  title=$(date -d "$first" '+%B %Y')
  pad=$(((width - 2 - ${#title}) / 2))
  lines+=("$(printf '%s‹%s%*s%s%*s%s›%s' "$dim" "$bright" "$pad" '' "$title" \
    "$((width - 2 - ${#title} - pad))" '' "$dim" "$reset")")
  lines+=('')

  line="$dim  "
  for c in 1 2 3 4 5 6 7; do
    name=$(date -d "2024-01-0$c" +%a) # 2024-01-01 was a Monday
    line+=" ${name:0:2}"
  done
  lines+=("$line$reset")

  # Always six week rows, so the grid keeps its height between months.
  for r in 0 1 2 3 4 5; do
    line=''
    if ((7 * r < offset + days)); then
      week=$(date -d "$start +$((7 * r)) days" +%V)
      line="$dim$week$reset"
      for c in 0 1 2 3 4 5 6; do
        n=$((7 * r + c - offset + 1))
        if ((n < 1 || n > days)); then
          line+='   '
        elif [[ $(printf '%04d-%02d-%02d' "$year" "$month" "$n") == "$now" ]]; then
          line+=" $today$(printf '%2d' "$n")$reset"
        elif ((c >= 5)); then
          line+=" $weekend$(printf '%2d' "$n")$reset"
        else
          line+=" $text$(printf '%2d' "$n")$reset"
        fi
      done
    fi
    lines+=("$line")
  done

  # Centre the block in whatever size the window ended up.
  read -r rows cols < <(stty size </dev/tty)
  x=$(((cols - width) / 2))
  y=$(((rows - ${#lines[@]}) / 2))
  if ((x < 0)); then x=0; fi
  if ((y < 0)); then y=0; fi

  printf '\e[2J'
  for r in "${!lines[@]}"; do
    printf '\e[%d;%dH%s' "$((y + r + 1))" "$((x + 1))" "${lines[r]}"
  done
}

# A trapped signal makes `read` return, so a resize redraws immediately.
trap : WINCH
this_month
while true; do
  draw
  key='' seq=''
  # Time out every minute so "today" follows midnight; >128 is a timeout or
  # signal, anything else non-zero is EOF.
  IFS= read -rsn1 -t 60 key || {
    (($? > 128)) && continue
    exit 0
  }
  if [[ $key == $'\e' ]]; then
    IFS= read -rsn2 -t 0.05 seq || true
    key+=$seq
  fi
  case $key in
  q | $'\e' | $'\e[O') exit 0 ;;
  h | k | $'\e[D' | $'\eOD' | $'\e[A' | $'\eOA') shift_month -1 ;;
  l | j | $'\e[C' | $'\eOC' | $'\e[B' | $'\eOB') shift_month 1 ;;
  H) shift_month -12 ;;
  L) shift_month 12 ;;
  t) this_month ;;
  esac
done
