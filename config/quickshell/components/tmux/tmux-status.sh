case "${1-}" in
  --refresh)
    # Signal 9 is reserved for the tmux module on both bars.
    pkill --signal RTMIN+9 --euid "$EUID" --exact 'waybar|\.waybar-wrapped' || true
    exit 0
    ;;
  "") ;;
  *) echo "Usage: tmux-status [--refresh]" >&2; exit 2 ;;
esac

# Keep menu visibility separate from tmux attachment/error state.
active=""
if visible=$(timeout --kill-after=1 1 "$quickshell" ipc --path "$shell_config" prop get tmux visible 2>/dev/null) && [[ "$visible" == true ]]; then
  active=active
fi

emit_status() {
  jq --compact-output --null-input --arg text "$1" --arg tooltip "$2" \
    --arg state "$3" --arg active "$active" \
    '{text: $text, tooltip: $tooltip, class: ([$state, $active] | map(select(length > 0)))}'
}

counts_format=$(< "$counts_format_file")
emit_counts() {
  local text
  local plural=s
  if [[ "$1" == 1 ]]; then plural=""; fi
  # The theme supplies the format; arguments are total, plural suffix, attached.
  # shellcheck disable=SC2059
  printf -v text "$counts_format" "$1" "$plural" "$2"
  emit_status "$text" "$3" "$4"
}

# Waybar needs only counts; window names stay inside Quickshell.
export LC_ALL=C
unset TMUX

if output=$(timeout --kill-after=1 2 "$tmux" -N -u -L default list-sessions -F '#{session_attached}' 2>&1); then
  total=0
  attached=0
  while IFS= read -r clients; do
    [[ -z "$clients" ]] && continue
    if [[ ! "$clients" =~ ^[0-9]+$ ]]; then
      emit_status "—" "tmux unavailable" error
      exit 0
    fi
    total=$((total + 1))
    # Count attached sessions, not the number of attached clients.
    if (( clients > 0 )); then
      attached=$((attached + 1))
    fi
  done <<< "$output"
  state=idle
  if (( attached > 0 )); then state=attached; fi
  emit_counts "$total" "$attached" "$total sessions · $attached attached" "$state"
elif [[ "$output" == "no server running on "* || "$output" == "error connecting to "*" (No such file or directory)" ]]; then
  emit_counts 0 0 "No sessions" idle
else
  emit_status "—" "tmux unavailable" error
fi
