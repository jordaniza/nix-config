if [[ $# -ne 1 || ! -f "$1" ]]; then
  echo "Screenshot unavailable." >&2
  exit 2
fi

timeout --kill-after=1 3 wl-copy --type image/png < "$1"
