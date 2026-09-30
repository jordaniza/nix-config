#!/usr/bin/env bash
# Launch kitty, detect its socket, and name the window automatically.
# Any arguments passed (like "tmux") are executed inside kitty.

SOCKET_BASE=/tmp/kitty-jordan.sock

# 1. Snapshot sockets before launch
before=$(ls -1 ${SOCKET_BASE}* 2>/dev/null)

# 2. Launch kitty with whatever command was given (defaults to interactive shell)
if [ $# -gt 0 ]; then
	kitty "$@" &
else
	kitty &
fi

# 3. Wait briefly for the new instance to create its socket
sleep 0.2

# 4. Find the new socket
after=$(ls -1 ${SOCKET_BASE}* 2>/dev/null)
new_socket=$(
	comm -13 \
		<(printf '%s\n' "$before" | sort) \
		<(printf '%s\n' "$after" | sort) |
		head -n1
)
# fallback: newest socket if diff failed
[ -z "$new_socket" ] && new_socket=$(ls -1t ${SOCKET_BASE}* 2>/dev/null | head -n1)

# 5. Derive numeric suffix for title
base=$(basename "$new_socket")
num=$(echo "$base" | sed -n 's/.*\.sock-//p')
[ -z "$num" ] && num=0
title="kitty-$num"

# 6. Rename the new kitty window
kitty @ --to "unix:$new_socket" set-window-title "$title" >/dev/null 2>&1
