#!/bin/sh
set -eu

# Hyprland 0.55 ignores cyclenext's visible argument; select visible clients directly.
monitors=$(hyprctl -j monitors)
clients=$(hyprctl -j clients)
active=$(hyprctl -j activewindow)
target=$(printf '%s\n' "$clients" | jq -r --argjson monitors "$monitors" --argjson active "$active" '
  [$monitors[] | .activeWorkspace.id, .specialWorkspace.id | select(. != null and . != 0)] as $visible
  | map(select(.mapped and .floating and (.hidden | not)
      and (.pinned or (.workspace.id as $id | $visible | index($id) != null))))
  | map(.address)
  | if length == 0 then ""
    else (index($active.address) // -1) as $current | .[($current + 1) % length]
    end
')
[ -n "$target" ] || exit 0
exec hyprctl dispatch focuswindow "address:$target"
