case "${1-}" in
  --refresh)
    # Signal 8 is reserved for the power module on both Waybar configurations.
    pkill --signal RTMIN+8 --euid "$EUID" --exact 'waybar|\.waybar-wrapped' || true
    exit 0
    ;;
  "") ;;
  *) echo "Usage: power-menu-status [--refresh]" >&2; exit 2 ;;
esac

if visible=$(timeout --kill-after=1 1 "$quickshell" ipc --path "$shell_config" prop get power visible 2>/dev/null) && [[ "$visible" == true ]]; then
  printf '%s\n' '{"text":"power","class":"active"}'
else
  printf '%s\n' '{"text":"power","class":""}'
fi
