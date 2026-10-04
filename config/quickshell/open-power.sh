report_failure() {
  local exit_status=$?
  if (( exit_status != 0 )); then
    echo "Power menu could not open. Read logs with:" >&2
    printf 'quickshell log --path "%s" --tail 100\n' "$shell_config" >&2
    timeout --kill-after=1 2 notify-send \
      --app-name="Power menu" --icon=dialog-error \
      "Power menu could not open" || true
  fi
}

# One deadline covers waiting for the launch lock, startup and the IPC request.
# --close keeps flock's descriptor out of the long-lived Quickshell process.
case "${1-}" in
  "")
    trap report_failure EXIT
    : "${XDG_RUNTIME_DIR:?A user runtime directory is required}"
    readonly startup_seconds=5
    timeout --kill-after=1 "$startup_seconds" \
      flock --close "$XDG_RUNTIME_DIR/power.lock" "$0" --locked
    exit 0
    ;;
  --locked) ;;
  *) echo "Usage: power-menu" >&2; exit 2 ;;
esac

open_menu() {
  local opened
  opened=$("$quickshell" ipc --path "$shell_config" call power open) || return
  [[ "$opened" == true ]]
}

if open_menu >/dev/null 2>&1; then
  exit 0
fi

# In 0.3.0 daemonized startup returns after loading the root and starting IPC.
"$quickshell" --path "$shell_config" --daemonize --no-duplicate
if ! open_menu; then
  exit 1
fi
