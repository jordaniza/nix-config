#!/usr/bin/env bash
set -euo pipefail

args=()
case "${1:-full}" in
  full) ;;
  region)
    geometry="$(slurp)" || exit 0
    [[ -n "$geometry" ]] || exit 0
    args=(-g "$geometry")
    ;;
  *)
    echo "Usage: screenshot [full|region]" >&2
    exit 2
    ;;
esac

dir="$HOME/Pictures/Screenshots"
mkdir -p "$dir"
file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"

grim "${args[@]}" "$file"
wl-copy < "$file"
notify-send "Screenshot" "Saved and copied"
