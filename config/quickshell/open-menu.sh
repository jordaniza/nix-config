readonly request_timeout=3
readonly notification_timeout=2

# Exit successfully only if IPC succeeds and QML confirms the menu opened.
if result=$(timeout --kill-after=1 "$request_timeout" \
    "$quickshell" ipc --path "$shell_config" call "$menu_target" open); then
  if [[ "$result" == "true" ]]; then
    exit 0
  fi
fi

# Otherwise, report the failure to the terminal and desktop.
echo "$menu_title could not open." >&2

if ! timeout --kill-after=1 "$notification_timeout" \
    notify-send --app-name="$menu_title" --icon=dialog-error \
    "$menu_title could not open"; then
  echo "Could not deliver the error notification." >&2
fi

exit 1
